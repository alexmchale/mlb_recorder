class Conf

  class << self

    %i(
      mlb_username
      mlb_password
      time_zone_name
      favorite_team_name
    ).each do |key|

      define_method "#{ key }" do
        Conf[key.to_s]
      end

      define_method "#{ key }=" do |value|
        Conf[key.to_s] = value
      end

      define_method "#{ key }?" do
        Conf[key.to_s].to_s.strip != ""
      end

    end

    def filename
      File.expand_path "~/.mlbrec.yaml"
    end

    def read
      if File.file? filename
        YAML.load File.read filename
      else
        {}
      end
    end

    def write(hash)
      File.open(filename, "w") { |f| f.write YAML.dump(hash) }
    end

    def [](key)
      read[key.to_s]
    end

    def []=(key, value)
      write(read.tap { |hash| hash[key.to_s] = value })
    end

    def time_zone
      ActiveSupport::TimeZone.all.find { |zone| zone.name == time_zone_name }
    end

    def favorite_team
      MlbTeam.find(favorite_team_name) if favorite_team_name?
    end

  end

end
