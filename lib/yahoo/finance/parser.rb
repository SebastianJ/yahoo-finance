require 'date'

module Yahoo
  module Finance

    class Parser
      
      def initialize
        
      end
      
      def parse_prices(parsed)
        data                =   []
        parsed              =   parsed.fetch("chart", {}).fetch("result", []).first
        meta                =   parsed.fetch("meta", {})
        timestamps          =   parsed.fetch("timestamp", []).collect { |epoch| convert_epoch_to_datetime(epoch) }
        
        indicators          =   parsed.fetch("indicators", {})
        quote               =   indicators.fetch("quote", []).first
        
        lows                =   quote.fetch("low", [])
        highs               =   quote.fetch("high", [])
        closes              =   quote.fetch("close", [])
        opens               =   quote.fetch("open", [])
        volumes             =   quote.fetch("volume", [])
        
        unadjusted_closes   =   indicators.fetch("unadjclose", []).first.fetch("unadjclose", [])
        adjusted_closes     =   indicators.fetch("adjclose", []).first.fetch("adjclose", [])

        timestamps.each_with_index do |timestamp, index|
          data  <<   {
            time:               timestamp,
            low:                lows[index],
            high:               highs[index],
            open:               opens[index],
            close:              closes[index],
            volume:             volumes[index],
            unadjusted_close:   unadjusted_closes[index],
            adjusted_close:     adjusted_closes[index]
          }
        end
        
        return data
      end
      
      def calculate_average(data, type: :sma, count: 9)
        Indicators::Data.new(data).calc(type: type, params: count).output
      end
      
      def convert_epoch_to_datetime(epoch)
        Time.at(epoch).utc
      end
      
    end

  end
end
