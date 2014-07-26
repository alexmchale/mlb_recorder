class MlbError < StandardError ; end

class GameNotFound   < MlbError ; end
class GameNotStarted < MlbError ; end
class MediaNotFound  < MlbError ; end
