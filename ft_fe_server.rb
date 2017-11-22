require_relative './cheater_stuff'

module Smash
  class FtFeServer
    include Smash::CheaterStuff

    attr_accessor :clues

    def initialze(**opts)
      @project_root = File.expand_path(__FILE__)
      @message = String.new
    end

    def self.build(**opts)
      client = new
      client.inject_workflow(client.workflow_description)
      client
    end

    def self.create(**opts); self.build(**opts); end

    def get_clues(file = './local/clean.csv')
      csv_arrs = CSV.read(file)
      headers = csv_arrs.shift
      @raw_clues =
        CSV::Table.new(csv_arrs.map { |row_arr| CSV::Row.new(headers, row_arr) })
    end

    def build_client(clues = current_clues)
      @current_client = Smash::ClientClassBuilder.build_client(clues, client_workflow_description)
    end

    # Make the client do what it does
    def deploy_client
      until(@current_client.done?)
        @current_client.next!
      end
    end

    def fin_insts
      @raw_clues['fiName'].uniq
    end

    # organize the clues from the csv.  this might not be needed in production
    # because the interrogator side does this sort of thing
    def organize_clues
      # map over financial institutions
      # get all rows with that FI
      # put
      unless @organized_clues
        headers = @raw_clues.headers
        @organized_clues = fin_insts.inject([]) do |clues_arr, fi|
          clues_hash = {}
          new_clues = @raw_clues.select { |row| row['fiName'] == fi }

          clues_hash[:url] = new_clues.select { |clue| !clue['url'].nil? }.first['url']

          new_clues.each do |row|
            search = if row['name'].nil? || row['name'].empty?
              "##{row['id']}"
            else
              "input[name='#{row['name']}']"
            end

            el_name = case row[row.headers.select { |h| h =~ /Input/ }.first]
            when 'A'
              :login_button
            when 'U'
              :username_field
            when 'P'
              :password_field
            else
              (0...8).map { (65 + rand(26)).chr }.join.downcase.to_sym
            end

            clues_hash[el_name] = search
          end
          clues_arr << clues_hash
        end
      end

      @organized_clues
    end

    def current_clues
      @organized_clues.shift
    end

    def done?
      @organized_clues.empty? || super
    end

    def next!
      puts "server moving to #{current_state.events.first.first}"
      self.public_send "#{current_state.events.first.first}!"
    end
  end
end

server = Smash::FtFeServer.create

until(server.done?)
  server.next!
end
puts 'all done, i suppose'
