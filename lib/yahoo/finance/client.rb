module Yahoo
  module Finance

    class Client
      attr_accessor :client, :url, :options, :verbose, :parser
      
      def initialize(verbose: false)
        self.client           =   ::HttpUtilities::Http::Client.new
        self.url              =   "https://query%d.finance.yahoo.com" % (1..2).to_a.sample
        self.verbose          =   verbose
        self.parser           =   Yahoo::Finance::Parser.new
        
        set_options
      end
    
      def set_options
        self.options          =   {
          follow_redirects_limit: 10,
          response_adapters:      [:json]
        }
      
        self.options[:response_adapters] << :logger if self.verbose
      end
  
      def set_proxy(proxy)
        self.options[:proxy]  =   proxy
      end
      
      def prices(from:, to:, periods: {start: Time.utc(2010,07,17), stop: Time.now.utc}, range: nil, interval: '1d', include_pre_post_market_prices: false)
        data                  =   nil
        id                    =   "#{from.to_s.upcase}-#{to.to_s.upcase}"
        
        arguments             =   {
          'interval'        =>  interval,
          'includePrePost'  =>  include_pre_post_market_prices,
        }
        
        if periods && !periods.empty? && periods[:start] && periods[:stop]
          start               =   periods[:start].to_i
          stop                =   periods[:stop].to_i
          
          arguments.merge!({'period1' => start, 'period2' => stop}) 
        end

        arguments.merge!({'range' => range}) if range
        
        response              =   chart(id: id, arguments: arguments)
        
        if response&.body
          data                =   self.parser.parse_prices(response.body)
        end
        
        return data
      end
      
      def chart(id:, arguments: {}, api_version: 8)
        request_url           =   "#{self.url}/v#{api_version}/finance/chart/#{id}"
        response              =   self.client.get(request_url, arguments: arguments, options: self.options)
      end

    end

  end
end
