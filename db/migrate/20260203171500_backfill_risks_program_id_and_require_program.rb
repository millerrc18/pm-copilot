class BackfillRisksProgramIdAndRequireProgram < ActiveRecord::Migration[7.1]
  def up
    say_with_time "Backfill risk program_id from contracts" do
      execute <<~SQL
        UPDATE risks
        SET program_id = contracts.program_id
        FROM contracts
        WHERE risks.program_id IS NULL
          AND risks.contract_id = contracts.id
      SQL
    end

    remaining = select_value("SELECT COUNT(*) FROM risks WHERE program_id IS NULL").to_i
    raise "Risks without program_id remain" if remaining.positive?

    change_column_null :risks, :program_id, false
  end

  def down
    change_column_null :risks, :program_id, true
  end
end
