
module Term

	def self.goto(x, y)
		"\u001b[#{y};#{x}H"
	end

  def self.clear_screen
    "\u001b[2J"
  end

  def self.clear_eol
    "\u001b[K"
  end

  def self.move_up(n=1)
  	"\u001b[#{n}A"
  end

  def self.move_down(n=1)
  	"\u001b[#{n}B"
  end

end
