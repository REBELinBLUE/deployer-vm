require 'json'

def loadConfig()

    config = {}
    config["override"] = {}
    config["default"] = {}

    if File.exists?(File.expand_path "./config.json")
        config["override"] = JSON.parse(File.read(File.expand_path "./config.json"))
    end

    if File.exists?(File.expand_path "./config.default.json")
        config["default"] = JSON.parse(File.read(File.expand_path "./config.default.json"))
    end

    result = config["default"]

    config["override"].each do |key, value|
        result[key] = value;
    end

    return result

end
