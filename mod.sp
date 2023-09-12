mod "tools_team_issue_tracker" {
  # hub metadata
  title         = "Github Issue Tracker for Steampipe Tools Team"
  description   = "Github Issue Tracker for Steampipe Tools Team."
  color         = "#191717"
  
  require {
    plugin "github" {
      min_version = "0.30.0"
    }
  }
}