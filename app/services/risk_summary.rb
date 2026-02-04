class RiskSummary
  def initialize(scope)
    @scope = scope
  end

  def call
    exposure_totals = Risk.exposure_totals(@scope)

    {
      total: @scope.count,
      open_risks: @scope.where(status: "open", risk_type: "risk").count,
      open_opportunities: @scope.where(status: "open", risk_type: "opportunity").count,
      open_items: @scope.where(status: "open").count,
      monitoring: @scope.where(status: "monitoring").count,
      high_severity: @scope.where("severity_score >= ?", 12).count,
      opportunities: @scope.where(risk_type: "opportunity").count,
      due_soon: @scope.where(due_date: Date.current..(Date.current + 14.days))
        .where.not(status: "closed")
        .count,
      risk_exposure: exposure_totals[:risk_total],
      opportunity_exposure: exposure_totals[:opportunity_total],
      net_exposure: exposure_totals[:net_exposure]
    }
  end
end
