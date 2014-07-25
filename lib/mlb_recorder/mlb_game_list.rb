class MlbGameList

  attr_reader :date
  attr_reader :games

  def initialize(date = Date.today)
    @date  = date
    @json  = Typhoeus.get(mlb_media_center_grid_url, followlocation: true).body
    @data  = JSON.load(@json)
    @games = @data["data"]["games"]["game"].map { |game_data| MlbGame.new(game_data) }
  rescue Exception => e
    [ mlb_media_center_grid_url, @date, @json, @data, @games ].each do |obj|
      puts
      ap obj
    end
    puts
    raise e
  end

  def mlb_media_center_grid_url
    y = date.strftime("%Y")
    m = date.strftime("%m")
    d = date.strftime("%d")

    "http://mlb.mlb.com/gdcross/components/game/mlb/year_#{y}/month_#{m}/day_#{d}/grid.json"
  end

  def find_game(id)
    games.find { |g| g.id == id } or raise(GameNotFound, "cannot find game #{id.inspect}")
  end

  def find_with_team(team)
    team = MlbTeam.find(team) unless team.kind_of?(MlbTeam)

    games.select do |game|
      (game.home_team == team) || (game.away_team == team)
    end
  end

  def self.game(id)
    date = Date.parse(id[/^\d+-\d+-(\d{4}-\d{2}-\d{2})$/, 1])
    new(date).find_game(id)
  end

  class GameNotFound < StandardError ; end

end
