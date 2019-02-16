class Admins::RevieweeOrgsController < Admins::BaseController
  def create
    @org = Org.find(params[:org_id])
    @reviewee = Reviewee.find(params[:reviewee_id])
    @reviewee_org = @org.reviewee_orgs.new(reviewee: @reviewee)
    if @reviewee_org.save
      redirect_to [:admins, @org], success: "#{@reviewee.github_account&.nickname}さんをアサインしました"
    else
      @reviewees = Reviewee.all.includes(:github_account)
      render 'admins/orgs/show'
    end
  end

  def destroy
    @org = Org.find(params[:org_id])
    @reviewee_org = @org.reviewee_orgs.find(params[:id])
    @reviewee = @reviewee_org.reviewee
    if @reviewee_org.destroy
      redirect_to [:admins, @org], success: "#{@reviewee.github_account&.nickname}さんをアサインから外しました"
    else
      @reviewees = Reviewee.all.includes(:github_account)
      render 'admins/repos/show'
    end
  end
end
