require "sinatra"
require "sqlite3"
require "chunky_png"

class NumberPNG
  module Segments
    # See: https://en.wikipedia.org/wiki/Seven-segment_display
    A = [[2,1], [3,1], [4,1]]
    B = [[5,2], [5,3], [5,4]]
    C = [[5,6], [5,7], [5,8]]
    D = [[2,9], [3,9], [4,9]]
    E = [[1,6], [1,7], [1,8]]
    F = [[1,2], [1,3], [1,4]]
    G = [[2,5], [3,5], [4,5]]

    MAPPING = {
      0 => [A, B, C, D, E, F],
      1 => [B, C],
      2 => [A, B, D, E, G],
      3 => [A, B, C, D, G],
      4 => [B, C, F, G],
      5 => [A, C, D, F, G],
      6 => [A, C, D, E, F, G],
      7 => [A, B, C],
      8 => [A, B, C, D, E, F, G],
      9 => [A, B, C, D, F, G],
    }
  end

  def initialize(number)
    @digits = number.to_s.chars.map(&:to_i)
  end

  def to_png_blob
    png = ChunkyPNG::Image.new(7 * @digits.size, 11, ChunkyPNG::Color::BLACK)
    offset = 0
    @digits.each do |digit|
      Segments::MAPPING[digit].each do |segment|
        segment.each do |x, y|
          png[x + offset, y] = ChunkyPNG::Color.rgb(0, 255, 0)
        end
      end
      offset += 7
    end
    png.to_datastream.to_blob
  end
end

DATABASE_FILE = "pageviews.db"

create_tables = !File.exist?(DATABASE_FILE)

db = SQLite3::Database.new(DATABASE_FILE)

if create_tables
  db.execute <<-SQL
CREATE TABLE pageviews (
  name varchar(255),
  count int
);
SQL
end

get "/pageviews/:name.png" do
  name = params[:name]
  result = db.execute "SELECT count FROM pageviews WHERE name = ?", name
  existing_count = result.empty? ? 0 : result[0][0]
  new_count = existing_count + 1

  if existing_count == 0
    db.execute "INSERT INTO pageviews VALUES (?, ?)", name, new_count
  else
    db.execute "UPDATE pageviews SET count = ? WHERE name = ?", new_count, name
  end

  status 200
  content_type 'image/png'
  cache_control :no_store
  NumberPNG.new(new_count.to_s.rjust(7, "0")).to_png_blob
end
