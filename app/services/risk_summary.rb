class RiskSummary
  def initialize(scope)
    @scope = scope
  end

  def call
    {
      total: @scope.count,
      open_items: @scope.where(status: "open").count,
      monitoring: @scope.where(status: "monitoring").count,
      high_severity: @scope.where("severity_score >= ?", 12).count,
      opportunities: @scope.where(risk_type: "opportunity").count
    }
  end
end
