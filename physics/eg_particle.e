note
	description: "[
			An EG_PARTICLE has a mass and a position. Plus three values dx, dy and dt
			which can be used to solve differential equations.
				]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "Benno Baumgartner"
	date: "$Date$"
	revision: "$Revision$"

class
	EG_PARTICLE

create
	make

feature {NONE} -- Initialization

	make (a_x, a_y: INTEGER; a_mass: like mass)
			-- Make a particle with `a_mass' at position (`a_x', `a_y').
		do
			internal_x := a_x
			internal_y := a_y
			mass := a_mass
		ensure
			set: x = a_x and y = a_y and mass = a_mass
		end

feature -- Access

	x: INTEGER
			-- x position of particle.
		do
			Result := internal_x
		end

	y: INTEGER
			-- y position of particle.
		do
			Result := internal_y
		end

	mass: DOUBLE
			-- The mass of the particle.

	dx: DOUBLE
			-- Delta to x direction.

	dy: DOUBLE
			-- Delta to y direction.

	dt: DOUBLE
			-- Delta time.

feature -- Element change

	set_delta (a_dx, a_dy: DOUBLE)
			-- Set `dx' to `a_dx' and `dy' to `a_dy'.
		do
			dx := a_dx
			dy := a_dy
		ensure
			set: dx = a_dx and dy = a_dy
		end

	set_dt (a_dt: DOUBLE)
			-- Set `dt' to `a_dt'.
		do
			dt := a_dt
		ensure
			set: dt = a_dt
		end

feature {NONE} -- Implementation

	internal_x: INTEGER
			-- Internal `x' position.

	internal_y: INTEGER;
			-- Internal `y' position.

note
	copyright:	"Copyright (c) 1984-2014, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"




end -- class EG_PARTICLE

