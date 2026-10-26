import Foundation

public final class ExportReportService {
    public static let shared = ExportReportService()

    private init() {}

    private var downloadsDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads")
    }

    // Export Session Summary to CSV
    public func exportCSV(stats: TokenStats, agents: [AgentModel], model: String) -> URL? {
        let dateFormatter = ISO8601DateFormatter()
        let nowStr = dateFormatter.string(from: Date())

        // UTF-8 BOM for seamless opening in Microsoft Excel
        var csv = "\u{FEFF}"
        csv += "Timestamp,AI_Model,Input_Tokens,Output_Tokens,Cached_Tokens,Total_Tokens,Estimated_Cost_USD,Active_Agents\n"
        csv += "\(nowStr),\"\(model)\",\(stats.inputTokens),\(stats.outputTokens),\(stats.cachedTokens),\(stats.totalTokens),\(String(format: "%.4f", stats.estimatedCostUSD)),\(agents.count)\n\n"

        csv += "Agent,Provider,State,Session_Tokens,Current_Action\n"
        for agent in agents {
            csv += "\"\(agent.name)\",\"\(agent.provider.rawValue)\",\"\(agent.state.rawValue)\",\(agent.tokensSession),\"\(agent.currentAction.replacingOccurrences(of: "\"", with: "\"\""))\"\n"
        }

        let filename = "UseTokenBar_Session_\(Int(Date().timeIntervalSince1970)).csv"
        let targetURL = downloadsDirectory.appendingPathComponent(filename)

        do {
            try csv.write(to: targetURL, atomically: true, encoding: .utf8)
            return targetURL
        } catch {
            return nil
        }
    }

    // Export Daily Usage History to CSV
    public func exportDailyHistoryCSV(records: [DailyUsageRecord]) -> URL? {
        var csv = "\u{FEFF}"
        csv += "Index,Timestamp,IDE,Agent,Model,Tokens,Estimated_Cost_USD\n"

        for (i, r) in records.enumerated() {
            let timeStr = r.timestamp.formatted(date: .numeric, time: .standard)
            csv += "\(i + 1),\"\(timeStr)\",\"\(r.ide)\",\"\(r.agentName)\",\"\(r.modelName)\",\(r.tokens),\(String(format: "%.4f", r.costUSD))\n"
        }

        let filename = "UseTokenBar_DailyHistory_\(Int(Date().timeIntervalSince1970)).csv"
        let targetURL = downloadsDirectory.appendingPathComponent(filename)

        do {
            try csv.write(to: targetURL, atomically: true, encoding: .utf8)
            return targetURL
        } catch {
            return nil
        }
    }

    // Export Daily Usage History to Excel Workbook (.xls)
    public func exportDailyHistoryExcel(records: [DailyUsageRecord]) -> URL? {
        var xml = """
<?xml version="1.0"?>
<?mso-application progid="Excel.Sheet"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">
 <Styles>
  <Style ss:ID="Header">
   <Font ss:Bold="1" ss:Color="#FFFFFF"/>
   <Interior ss:Color="#007AFF" ss:Pattern="Solid"/>
   <Alignment ss:Horizontal="Center"/>
  </Style>
  <Style ss:ID="Tokens">
   <NumberFormat ss:Format="#,##0"/>
   <Font ss:Color="#007AFF"/>
   <Alignment ss:Horizontal="Right"/>
  </Style>
  <Style ss:ID="Currency">
   <NumberFormat ss:Format="$#,##0.000"/>
   <Alignment ss:Horizontal="Right"/>
  </Style>
  <Style ss:ID="Center">
   <Alignment ss:Horizontal="Center"/>
  </Style>
 </Styles>
 <Worksheet ss:Name="Daily Token History">
  <Table>
   <Column ss:Width="45"/>
   <Column ss:Width="130"/>
   <Column ss:Width="110"/>
   <Column ss:Width="120"/>
   <Column ss:Width="120"/>
   <Column ss:Width="80"/>
   <Column ss:Width="90"/>
   <Row ss:StyleID="Header">
    <Cell><Data ss:Type="String">#</Data></Cell>
    <Cell><Data ss:Type="String">Timestamp</Data></Cell>
    <Cell><Data ss:Type="String">IDE</Data></Cell>
    <Cell><Data ss:Type="String">Agent</Data></Cell>
    <Cell><Data ss:Type="String">Model</Data></Cell>
    <Cell><Data ss:Type="String">Tokens</Data></Cell>
    <Cell><Data ss:Type="String">Cost (USD)</Data></Cell>
   </Row>
"""

        for (i, r) in records.enumerated() {
            let timeStr = r.timestamp.formatted(date: .numeric, time: .standard)
            xml += """
   <Row>
    <Cell ss:StyleID="Center"><Data ss:Type="Number">\(i + 1)</Data></Cell>
    <Cell ss:StyleID="Center"><Data ss:Type="String">\(timeStr)</Data></Cell>
    <Cell><Data ss:Type="String">\(r.ide)</Data></Cell>
    <Cell><Data ss:Type="String">\(r.agentName)</Data></Cell>
    <Cell><Data ss:Type="String">\(r.modelName)</Data></Cell>
    <Cell ss:StyleID="Tokens"><Data ss:Type="Number">\(r.tokens)</Data></Cell>
    <Cell ss:StyleID="Currency"><Data ss:Type="Number">\(r.costUSD)</Data></Cell>
   </Row>
"""
        }

        xml += """
  </Table>
 </Worksheet>
</Workbook>
"""

        let filename = "UseTokenBar_DailyHistory_\(Int(Date().timeIntervalSince1970)).xls"
        let targetURL = downloadsDirectory.appendingPathComponent(filename)

        do {
            try xml.write(to: targetURL, atomically: true, encoding: .utf8)
            return targetURL
        } catch {
            return nil
        }
    }
}
