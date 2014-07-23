class MlbTeam

  TEAM_DATA = {
    "ari" => {
      :name       => "Arizona Diamondbacks",
      :short_name => "Diamondbacks",
      :time_zone  => :arizona,
    },
    "atl" => {
      :name       => "Atlanta Braves",
      :short_name => "Braves",
      :time_zone  => :eastern,
    },
    "bal" => {
      :name       => "Baltimore Orioles",
      :short_name => "Orioles",
      :time_zone  => :eastern,
    },
    "bos" => {
      :name       => "Boston Red Sox",
      :short_name => "Red Sox",
      :time_zone  => :eastern,
    },
    "chn" => {
      :name       => "Chicago Cubs",
      :short_name => "Cubs",
      :time_zone  => :central,
    },
    "cha" => {
      :name       => "Chicago White Sox",
      :short_name => "White Sox",
      :time_zone  => :central,
    },
    "cin" => {
      :name       => "Cincinnati Reds",
      :short_name => "Reds",
      :time_zone  => :eastern,
    },
    "cle" => {
      :name       => "Cleveland Indians",
      :short_name => "Indians",
      :time_zone  => :eastern,
    },
    "col" => {
      :name       => "Colorado Rockies",
      :short_name => "Rockies",
      :time_zone  => :mountain,
    },
    "det" => {
      :name       => "Detroit Tigers",
      :short_name => "Tigers",
      :time_zone  => :eastern,
    },
    "hou" => {
      :name       => "Houston Astros",
      :short_name => "Astros",
      :time_zone  => :central,
    },
    "kan" => {
      :name       => "Kansas City Royals",
      :short_name => "Royals",
      :time_zone  => :central,
    },
    "laa" => {
      :name       => "Los Angeles Angels of Anaheim",
      :short_name => "Angels",
      :time_zone  => :pacific,
    },
    "lan" => {
      :name       => "Los Angeles Dodgers",
      :short_name => "Dodgers",
      :time_zone  => :pacific,
    },
    "mia" => {
      :name       => "Miami Marlins",
      :short_name => "Marlins",
      :time_zone  => :eastern,
    },
    "mil" => {
      :name       => "Milwaukee Brewers",
      :short_name => "Brewers",
      :time_zone  => :central,
    },
    "min" => {
      :name       => "Minnesota Twins",
      :short_name => "Twins",
      :time_zone  => :central,
    },
    "nyn" => {
      :name       => "New York Mets",
      :short_name => "Mets",
      :time_zone  => :eastern,
    },
    "nya" => {
      :name       => "New York Yankees",
      :short_name => "Yankees",
      :time_zone  => :eastern,
    },
    "oak" => {
      :name       => "Oakland Athletics",
      :short_name => "Athletics",
      :time_zone  => :pacific,
    },
    "phi" => {
      :name       => "Philadelphia Phillies",
      :short_name => "Phillies",
      :time_zone  => :eastern,
    },
    "pit" => {
      :name       => "Pittsburgh Pirates",
      :short_name => "Pirates",
      :time_zone  => :eastern,
    },
    "san" => {
      :name       => "San Diego Padres",
      :short_name => "Padres",
      :time_zone  => :pacific,
    },
    "gia" => {
      :name       => "San Francisco Giants",
      :short_name => "Giants",
      :time_zone  => :pacific,
    },
    "sea" => {
      :name       => "Seattle Mariners",
      :short_name => "Mariners",
      :time_zone  => :pacific,
    },
    "stl" => {
      :name       => "St. Louis Cardinals",
      :short_name => "Cardinals",
      :time_zone  => :central,
    },
    "tam" => {
      :name       => "Tampa Bay Rays",
      :short_name => "Rays",
      :time_zone  => :eastern,
    },
    "tex" => {
      :name       => "Texas Rangers",
      :short_name => "Rangers",
      :time_zone  => :central,
    },
    "tor" => {
      :name       => "Toronto Blue Jays",
      :short_name => "Blue Jays",
      :time_zone  => :eastern,
    },
    "was" => {
      :name       => "Washington Nationals",
      :short_name => "Nationals",
      :time_zone  => :eastern,
    },
  }

  attr_reader :time_zone, :name, :short_name

  def initialize(team_data)
    @details = team_data


    @time_zone =
      ActiveSupport::TimeZone.us_zones.find do |zone|
        zone.name.downcase.index(@details[:time_zone].to_s)
      end

    @name       = @details[:name]
    @short_name = @details[:short_name]
  end

  def self.find(id)
    id = "Diamondbacks" if id == "D-backs"

    team_data ||= TEAM_DATA[id.to_s]
    team_data ||= TEAM_DATA.values.find { |team| team[:short_name] == id.to_s }

    raise "cannot find team details for #{ id.inspect }" unless team_data

    new team_data
  end

end
