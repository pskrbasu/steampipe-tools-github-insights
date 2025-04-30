mod "tools_team_issue_tracker" {
  # hub metadata
  title         = "Pipelings Repo Tracker"
  description   = "Pipelings Repo Tracker for Tools Team."
  color         = "#191717"
  
  require {
    plugin "github" {
      min_version = "0.30.0"
    }
  }
}