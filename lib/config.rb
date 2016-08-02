require 'json'

def loadConfig()

    config = {}
    config["override"] = {}
    config["default"] = {}

    myConfig = File.expand_path(File.join(File.dirname(__FILE__), "../config.json"))
    baseConfig = File.expand_path(File.join(File.dirname(__FILE__), "../config.default.json"))

    if File.exists?(myConfig)
        config["override"] = JSON.parse(File.read(myConfig))
    end

    if File.exists?(baseConfig)
        config["default"] = JSON.parse(File.read(baseConfig))
    end

    result = config["default"]

    config["override"].each do |key, value|
        result[key] = value;
    end

    return result

end
