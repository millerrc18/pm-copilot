class RiskExposureSnapshotter
  def initialize(program_scope: Program.all, snapshot_on: Date.current)
    @program_scope = program_scope
    @snapshot_on = snapshot_on
  end

  def call
    @program_scope.find_each do |program|
      RiskExposureSnapshot.capture_for_program(program, snapshot_on: @snapshot_on)
    end
  end
end
