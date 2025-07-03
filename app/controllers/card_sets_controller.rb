# app/controllers/card_sets_controller.rb
class CardSetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question
  before_action :set_card_set, only: [ :show, :edit, :update, :destroy ]
  before_action :ensure_question_owner, except: [ :show ]

  # GET /questions/:question_id/card_sets
  def index
    @card_sets = @question.card_sets.order(:created_at)
  end

  # GET /questions/:question_id/card_sets/:id
  def show
  end

  # GET /questions/:question_id/card_sets/new
  def new
    @card_set = @question.card_sets.build

    # カード上限チェック
    unless @question.can_add_card_set?(1, 1) # 最小構成での確認
      redirect_to @question, alert: "カード数が上限に達しています"
      nil
    end
  end

  # POST /questions/:question_id/card_sets
  def create
    @card_set = @question.card_sets.build(card_set_params)

    if @card_set.save
      @question.touch

      # カードセット数に応じてメッセージを分岐
      card_sets_count = @question.card_sets.count
      success_message = generate_success_message(card_sets_count)
      redirect_path = determine_redirect_path(card_sets_count)

      respond_to do |format|
        format.html { redirect_to redirect_path, notice: success_message }
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.append("card_sets", partial: "card_sets/card_set", locals: { card_set: @card_set, question: @question }),
            turbo_stream.update("card_limit_info", partial: "shared/card_limit_info", locals: { question: @question }),
            turbo_stream.update("flash_messages", html: %(<div class="alert alert-success shadow-lg my-2"><span>#{success_message}</span></div>).html_safe),
            turbo_stream.replace("new_card_set_form", partial: "questions/add_card_set_button", locals: { question: @question })
          ]
        }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.update("new_card_set_form", partial: "card_sets/form", locals: { card_set: @card_set, question: @question }),
            turbo_stream.update("card_limit_info", partial: "shared/card_limit_info", locals: { question: @question })
          ]
        }
      end
    end
  end

  # GET /questions/:question_id/card_sets/:id/edit
  def edit
  end

  # PATCH/PUT /questions/:question_id/card_sets/:id
  def update
    if @card_set.update(card_set_params)
      @question.touch

      respond_to do |format|
        format.html { redirect_to @question, notice: "カードセットを更新しました" }
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace(@card_set, partial: "card_sets/card_set", locals: { card_set: @card_set, question: @question }),
            turbo_stream.update("card_limit_info", partial: "shared/card_limit_info", locals: { question: @question }),
            turbo_stream.update("flash_messages", html: %(<div class="alert alert-success shadow-lg my-2"><span>カードセットを更新しました</span></div>).html_safe)
          ]
        }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("edit_card_set_#{@card_set.id}", partial: "card_sets/form", locals: { card_set: @card_set, question: @question })
        }
      end
    end
  end

  # DELETE /questions/:question_id/card_sets/:id
  def destroy
  # 最小カードセット数のチェック
  if @question.card_sets.count <= 2
    respond_to do |format|
      format.html { redirect_to @question, alert: "カードセットは2組以上必要です" }
      format.turbo_stream {
        render turbo_stream: turbo_stream.update(
          "flash_messages",
          html: %(<div class="alert alert-error shadow-lg my-2"><span>カードセットは2組以上必要です</span></div>).html_safe
        )
      }
    end
    return
  end

  @card_set.destroy
  @question.touch

  respond_to do |format|
    format.html { redirect_to @question, notice: "カードセットを削除しました" }
    format.turbo_stream {
      render turbo_stream: [
        turbo_stream.remove(view_context.dom_id(@card_set)),
        turbo_stream.update("card_limit_info", partial: "shared/card_limit_info", locals: { question: @question }),
        turbo_stream.update("flash_messages", html: %(<div class="alert alert-success shadow-lg my-2"><span>カードセットを削除しました</span></div>).html_safe)
      ]
    }
  end
end
  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def set_card_set
    @card_set = @question.card_sets.find(params[:id])
  end

  def ensure_question_owner
    unless @question.user_id == current_user.id
      redirect_to root_path, alert: "アクセス権限がありません"
    end
  end

  def card_set_params
    params.require(:card_set).permit(:origin_word, related_words: [])
  end

  # カードセット数に応じたメッセージを生成
  def generate_success_message(card_sets_count)
    case card_sets_count
    when 1
      "1組目完了！"
    when 2
      if @question.valid_for_game?
        "問題作成完了！ゲームを開始できます🎉"
      else
        "2組目完了！さらにカードセットを追加するか、問題を完成させてください"
      end
    else
      if @question.valid_for_game?
        "カードセットを追加しました！問題が完成しています🎉"
      else
        "カードセットを追加しました"
      end
    end
  end

  # カードセット数に応じたリダイレクト先を決定
  def determine_redirect_path(card_sets_count)
    case card_sets_count
    when 1
      # 1組目の場合は同じ画面に戻って追加を促す
      new_question_card_set_path(@question)
    when 2..Float::INFINITY
      if @question.valid_for_game?
        # ゲーム可能な状態なら問題詳細画面へ
        question_path(@question)
      else
        # まだゲーム不可能なら継続して編集
        new_question_card_set_path(@question)
      end
    else
      @question
    end
  end
end
