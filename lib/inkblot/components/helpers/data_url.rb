require 'base64'

module Inkblot
	module Components
		module Helpers
			# For handling data url creation for image producing components
			module DataUrl
	      # Encodes the binary string +bs+ into a base64 data url
	      def data_url_from_binary(bs, filetype='png')
	      	data_url = +"" << 'data:image/'
	      	data_url << filetype
	      	data_url << ';base64,'
	      	data_url << Base64.encode64(bs).gsub("\n", '')
	      end
	    end
	  end
	end
end