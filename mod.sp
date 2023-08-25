mod "tools_insights" {
  # hub metadata
  title         = "Github insights for Steampipe tools team"
  description   = "Github insights for Steampipe tools team."
  
  require {
    plugin "github" {
      min_version = "0.30.0"
    }
  }
}