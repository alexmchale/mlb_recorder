class MlbGameList

  attr_reader :date
  attr_reader :games

  def initialize(date = Date.today)
    @date  = date
    @json  = Net::HTTP.get(URI.parse(mlb_media_center_grid_url))
    @games = JSON.load(@json)["data"]["games"]["game"].map { |game_data| MlbGame.new(game_data) }
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

  def self.game(id)
    date = Date.parse(id[/^\d+-\d+-(\d{4}-\d{2}-\d{2})$/, 1])
    new(date).find_game(id)
  end

  class GameNotFound < StandardError ; end

end
