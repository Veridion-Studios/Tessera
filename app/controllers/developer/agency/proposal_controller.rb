module Developer
  module Agency
    class ProposalsController < ApplicationController
      include Developer::AgencyScoped
      before_action :require_agency_admin!, only: [:create, :update, :destroy, :submit, :withdraw]

      def index
        @proposals      = @agency.proposals.includes(:quote_request).order(created_at: :desc)
        @draft_count    = @proposals.select { |p| p.status == "draft" }.count
        @submitted_count = @proposals.select { |p| p.status == "submitted" }.count
      end

      def show
        @proposal     = @agency.proposals.find(params[:id])
        @quote_request = @proposal.quote_request
      end

      def create
        quote_request = QuoteRequest.find(params[:quote_request_id])
        @proposal = @agency.proposals.build(proposal_params)
        @proposal.quote_request = quote_request
        if @proposal.save
          redirect_to developer_agency_proposal_path(@proposal), notice: "Proposal saved as draft."
        else
          redirect_to developer_agency_proposals_path, alert: "Could not create proposal."
        end
      end

      def update
        @proposal = @agency.proposals.find(params[:id])
        if @proposal.editable? && @proposal.update(proposal_params)
          redirect_to developer_agency_proposal_path(@proposal), notice: "Proposal updated."
        else
          redirect_to developer_agency_proposal_path(@proposal), alert: "Cannot update submitted proposal."
        end
      end

      def destroy
        @proposal = @agency.proposals.find(params[:id])
        @proposal.destroy
        redirect_to developer_agency_proposals_path, notice: "Proposal removed."
      end

      def submit
        @proposal = @agency.proposals.find(params[:id])
        if @proposal.update(status: "submitted", submitted_at: Time.current)
          redirect_to developer_agency_proposal_path(@proposal), notice: "Proposal submitted."
        else
          redirect_to developer_agency_proposal_path(@proposal), alert: "Could not submit proposal."
        end
      end

      def withdraw
        @proposal = @agency.proposals.find(params[:id])
        @proposal.update!(status: "withdrawn")
        redirect_to developer_agency_proposals_path, notice: "Proposal withdrawn."
      end

      private

      def proposal_params
        params.require(:agency_proposal).permit(:pitch, :proposed_amount, :proposed_timeline)
      end
    end
  end
end