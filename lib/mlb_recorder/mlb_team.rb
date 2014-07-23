class MlbTeam

  TEAM_DATA = {
    "ari" => {
      :name       => "Arizona Diamondbacks",
      :short_name => "Diamondbacks",
      :time_zone  => :arizona,
      :color1     => :red,
    },
    "atl" => {
      :name       => "Atlanta Braves",
      :short_name => "Braves",
      :time_zone  => :eastern,
      :color1     => :red,
    },
    "bal" => {
      :name       => "Baltimore Orioles",
      :short_name => "Orioles",
      :time_zone  => :eastern,
      :color1     => :yellow,
    },
    "bos" => {
      :name       => "Boston Red Sox",
      :short_name => "Red Sox",
      :time_zone  => :eastern,
      :color1     => :red,
    },
    "chn" => {
      :name       => "Chicago Cubs",
      :short_name => "Cubs",
      :time_zone  => :central,
      :color1     => :blue,
    },
    "cha" => {
      :name       => "Chicago White Sox",
      :short_name => "White Sox",
      :time_zone  => :central,
      :color1     => :white,
    },
    "cin" => {
      :name       => "Cincinnati Reds",
      :short_name => "Reds",
      :time_zone  => :eastern,
      :color1     => :red,
    },
    "cle" => {
      :name       => "Cleveland Indians",
      :short_name => "Indians",
      :time_zone  => :eastern,
      :color1     => :red,
    },
    "col" => {
      :name       => "Colorado Rockies",
      :short_name => "Rockies",
      :time_zone  => :mountain,
      :color1     => :magenta,
    },
    "det" => {
      :name       => "Detroit Tigers",
      :short_name => "Tigers",
      :time_zone  => :eastern,
      :color1     => :blue,
    },
    "hou" => {
      :name       => "Houston Astros",
      :short_name => "Astros",
      :time_zone  => :central,
      :color1     => :yellow,
    },
    "kan" => {
      :name       => "Kansas City Royals",
      :short_name => "Royals",
      :time_zone  => :central,
      :color1     => :blue,
    },
    "laa" => {
      :name       => "Los Angeles Angels of Anaheim",
      :short_name => "Angels",
      :time_zone  => :pacific,
      :color1     => :red,
    },
    "lan" => {
      :name       => "Los Angeles Dodgers",
      :short_name => "Dodgers",
      :time_zone  => :pacific,
      :color1     => :blue,
    },
    "mia" => {
      :name       => "Miami Marlins",
      :short_name => "Marlins",
      :time_zone  => :eastern,
      :color1     => :green,
    },
    "mil" => {
      :name       => "Milwaukee Brewers",
      :short_name => "Brewers",
      :time_zone  => :central,
      :color1     => :blue,
    },
    "min" => {
      :name       => "Minnesota Twins",
      :short_name => "Twins",
      :time_zone  => :central,
      :color1     => :blue,
    },
    "nyn" => {
      :name       => "New York Mets",
      :short_name => "Mets",
      :time_zone  => :eastern,
      :color1     => :yellow,
    },
    "nya" => {
      :name       => "New York Yankees",
      :short_name => "Yankees",
      :time_zone  => :eastern,
      :color1     => :blue,
    },
    "oak" => {
      :name       => "Oakland Athletics",
      :short_name => "Athletics",
      :time_zone  => :pacific,
      :color1     => :green,
    },
    "phi" => {
      :name       => "Philadelphia Phillies",
      :short_name => "Phillies",
      :time_zone  => :eastern,
      :color1     => :red,
    },
    "pit" => {
      :name       => "Pittsburgh Pirates",
      :short_name => "Pirates",
      :time_zone  => :eastern,
      :color1     => :yellow,
    },
    "san" => {
      :name       => "San Diego Padres",
      :short_name => "Padres",
      :time_zone  => :pacific,
      :color1     => :cyan,
    },
    "gia" => {
      :name       => "San Francisco Giants",
      :short_name => "Giants",
      :time_zone  => :pacific,
      :color1     => :yellow,
    },
    "sea" => {
      :name       => "Seattle Mariners",
      :short_name => "Mariners",
      :time_zone  => :pacific,
      :color1     => :blue,
    },
    "stl" => {
      :name       => "St. Louis Cardinals",
      :short_name => "Cardinals",
      :time_zone  => :central,
      :color1     => :red,
    },
    "tam" => {
      :name       => "Tampa Bay Rays",
      :short_name => "Rays",
      :time_zone  => :eastern,
      :color1     => :cyan,
    },
    "tex" => {
      :name       => "Texas Rangers",
      :short_name => "Rangers",
      :time_zone  => :central,
      :color1     => :blue,
    },
    "tor" => {
      :name       => "Toronto Blue Jays",
      :short_name => "Blue Jays",
      :time_zone  => :eastern,
      :color1     => :blue,
    },
    "was" => {
      :name       => "Washington Nationals",
      :short_name => "Nationals",
      :time_zone  => :eastern,
      :color1     => :red,
    },
  }

  attr_reader :time_zone, :name, :short_name, :color1

  def initialize(team_data)
    @details = team_data

    @time_zone =
      ActiveSupport::TimeZone.us_zones.find do |zone|
        zone.name.downcase.index(@details[:time_zone].to_s)
      end

    @name       = @details[:name]
    @short_name = @details[:short_name]
    @color1     = @details[:color1]
  end

  def color1(s = nil, &b)
    (s || b.call).to_s.send(@color1)
  end

  def self.find(id)
    id = "Diamondbacks" if id == "D-backs"

    team_data ||= TEAM_DATA[id.to_s]
    team_data ||= TEAM_DATA.values.find { |team| team[:short_name] == id.to_s }

    raise "cannot find team details for #{ id.inspect }" unless team_data

    new team_data
  end

end
