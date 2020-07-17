class ArticlesController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  before_action :authenticate_admin!, only: [:create, :update, :destroy]
  before_action :set_article, only: [:show, :update, :destroy]


  # GET /articles
  def index
    if params[:section_id]
      @section = Section.friendly.find(params[:section_id])
      @articles = Article
                    #.where("sections.id = ?", @section.id)
                    .joins("LEFT JOIN sections ON sections.id = ANY articles.sections")
                    .order("articles.rank + 3 * sections.rank + 12 * articles.issue + 192 * articles.volume DESC")
    else
      @articles = Article
                   .joins("LEFT JOIN sections ON sections.id = ANY articles.sections")
                   .order("articles.rank + 3 * sections.rank + 12 * articles.issue + 192 * articles.volume DESC")
    end

    if params[:query]
      @articles = PgSearch.multisearch(params[:query])
    end

    @articles = @articles.order(:created_at).reverse if params[:order_by] == 'date'

    @articles = @articles.first(params[:limit].to_i) if params[:limit]

    @articles = @articles.select(
      :id,
      :title,
      :slug,
      :volume,
      :issue,
      :is_published,
      :created_at,
      :updated_at,
      :rank,
      :preview
    ) if params[:content] == 'false'

    render json: @articles
  end

  # GET /articles/1
  def show
    render json: @article
  end

  # POST /articles
  def create
   if @article.save
      render json: @article, status: :created, location: @article
   else
      render json: @article.errors, status: :unprocessable_entity
   end
  end

  # PATCH/PUT /articles/1
  def update
    if @article.update(article_params)
      render json: @article
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  # DELETE /articles/1
  def destroy
    @article.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.friendly.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def article_params
      params.require(:article).permit(
        :title,
        :slug,
        :content,
        :volume,
        :issue,
        :is_published,
        :section_id,
        :summary,
        :rank,
        :created_at
      )
    end
end
