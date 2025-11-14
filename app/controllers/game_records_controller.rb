class GameRecordsController < ApplicationController
  include FindQuestion

  before_action :authenticate_user!, only: %i[create batch_results]
  before_action :set_question, only: %i[create show]

  def create
    if user_signed_in?
      start_time = session[:game_start_time] || Time.current.to_f
      @game_record = GameRecord.create(
        user: current_user,
        question: @question,
        total_matches: session[:correct_matches]&.length || 0,
        accuracy: calculate_current_accuracy,
        completion_time_seconds: Time.current.to_f - start_time,
        given_up: params[:give_up] == "true" ? true : false
      )
    end

    # まとめてプレイモードの場合
    if session[:batch_play_mode]
      # 結果を保存
      session[:batch_play_results] ||= []
      session[:batch_play_results] << {
        question_id: @question.id,
        game_record_id: @game_record&.id,
        total_matches: session[:correct_matches]&.length || 0,
        accuracy: calculate_current_accuracy,
        completion_time_seconds: Time.current.to_f - start_time,
        given_up: params[:give_up] == "true"
      }

      # まとめてプレイを終了する場合は結果画面へ
      if params[:end_batch_play] == true || params[:end_batch_play] == "true"
        render json: {
          batch_play: true,
          next_url: batch_results_game_records_path
        }
        return
      end

      # 次の問題へ
      session[:batch_play_current_index] = (session[:batch_play_current_index] || 0) + 1
      question_ids = session[:batch_play_question_ids]

      if session[:batch_play_current_index] < question_ids.length
        # 次のゲームへ - JSONでリダイレクト先を返す
        render json: {
          batch_play: true,
          next_url: game_path(question_ids[session[:batch_play_current_index]])
        }
      else
        # 全て完了：結果画面へ - JSONでリダイレクト先を返す
        render json: {
          batch_play: true,
          next_url: batch_results_game_records_path
        }
      end
    else
      redirect_to game_record_path(@question)
    end
  end

  def show
    # ログインユーザーで最新のゲーム記録があれば、それを使用
    if user_signed_in?
      @latest_game_record = current_user.game_records.where(question: @question).order(:created_at).last
    end

    if @latest_game_record
      # 保存されたゲーム記録のデータを使用
      @total_matches = @latest_game_record.total_matches
      @total_clicks = session[:total_clicks] || 0
      @correct_clicks = session[:correct_clicks] || 0
      @accuracy = @latest_game_record.accuracy
      @game_duration = @latest_game_record.completion_time_seconds
    else
      # セッションからデータを取得（未ログインユーザー等）
      @total_matches = session[:correct_matches]&.length || 0
      @total_clicks = session[:total_clicks] || 0
      @correct_clicks = session[:correct_clicks] || 0
      @accuracy = @total_clicks > 0 ? (@correct_clicks.to_f / @total_clicks * 100).round(1) : 0

      # ゲーム時間計算
      start_time = session[:game_start_time] || Time.current.to_f
      @game_duration = Time.current.to_f - start_time
    end

    # 必要な組み合わせ数を計算
    @required_matches = session[:total_required_matches] || @question.card_sets.sum { |cs| cs.related_words.count }
  end

  def batch_results
    # まとめてプレイの結果を取得
    @results = session[:batch_play_results] || []
    @list_id = session[:batch_play_list_id]
    @list = List.find_by(id: @list_id)

    if @results.empty?
      redirect_to mypage_user_path, alert: "まとめてプレイの結果がありません"
      return
    end

    # 結果の詳細を取得（セッションのキーは文字列になっている可能性があるため両方対応）
    @detailed_results = @results.map do |result|
      # シンボルと文字列の両方に対応
      result = result.with_indifferent_access if result.is_a?(Hash)

      question = Question.find(result[:question_id])
      game_record = result[:game_record_id] ? GameRecord.find(result[:game_record_id]) : nil

      {
        question: question,
        game_record: game_record,
        total_matches: result[:total_matches],
        accuracy: result[:accuracy],
        completion_time_seconds: result[:completion_time_seconds],
        given_up: result[:given_up]
      }
    end

    # 統計情報を計算
    @total_games = @results.length
    @average_accuracy = (@results.sum { |r| (r[:accuracy] || r["accuracy"]).to_f } / @total_games.to_f).round(1)
    @total_time = @results.sum { |r| (r[:completion_time_seconds] || r["completion_time_seconds"]).to_f }
    @completed_games = @results.count { |r| !(r[:given_up] || r["given_up"]) }

    # OGP用に問題タイトルリストをセッションに保存（絵文字を除去）
    pattern = /[\p{Emoji}\p{Emoji_Component}&&[:^ascii:]]/

    # 条件でソート：ギブアップしていない、正答率が高い順、解答時間が短い順、問題作成が新しい順
    sorted_results = @detailed_results
      .reject { |r| r[:given_up] } # ギブアップしていない問題のみ
      .sort_by { |r| [ -r[:accuracy], r[:completion_time_seconds], -r[:question].created_at.to_i ] }

    # OGP用に問題IDをカンマ区切りで保存（最大3問＋総問題数）
    top_3_question_ids = sorted_results.take(3).map { |r| r[:question].id }
    @ogp_question_ids = "#{top_3_question_ids.join(',')}&total=#{@detailed_results.length}"

    # セッションをクリア
    clear_batch_play_session
  end

  private

  def game_record_params
    params.require(:game_record).permit(:total_matches, :accuracy, :completion_time_seconds, :given_up)
  end

  def calculate_current_accuracy
    return 0 if session[:total_clicks].to_i == 0
    (session[:correct_clicks].to_f / session[:total_clicks] * 100).round(1)
  end

  def clear_batch_play_session
    session.delete(:batch_play_mode)
    session.delete(:batch_play_question_ids)
    session.delete(:batch_play_current_index)
    session.delete(:batch_play_results)
    session.delete(:batch_play_list_id)
  end
end
