note
	description: "Objects that holds common properties for EG_SPRING_ENERGY and EG_SPRING_PARTICLE."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "Benno Baumgartner"
	date: "$Date$"
	revision: "$Revision$"

class
	EG_FORCE_DIRECTED_PHYSICS_PROPERTIES

create
	default_create

feature -- Access

	electrical_repulsion: REAL_64 assign set_electrical_repulsion
			-- Repulsion between particles in the system.

	stiffness: REAL_64 assign set_stiffness
			-- Stiffness of all links connecting particles.

	center_x: INTEGER
			-- X position of the center.

	center_y: INTEGER
			-- Y position of the center.

	center_attraction: REAL_64 assign set_center_attraction
			-- Attraction of the center for particles.

feature -- Element change

	set_center_attraction (a_value: like center_attraction)
			-- Set `center_attraction' to `a_value'.
		require
			valid_value: a_value >= 0.0
		do
			center_attraction := a_value
		ensure
			set: center_attraction = a_value
		end

	set_stiffness (a_value: like stiffness)
			-- Set `stiffness' to `a_value'.
		require
			valid_value: a_value >= 0.0
		do
			stiffness := a_value
		ensure
			set: stiffness = a_value
		end

	set_electrical_repulsion (a_value: like electrical_repulsion)
			-- Set `electrical_repulsion' to `a_value'.
		require
			valid_value: a_value >= 0.0
		do
			electrical_repulsion := a_value
		ensure
			set: electrical_repulsion = a_value
		end

	set_center (a_x, a_y: INTEGER)
			-- Set `center_x' to `a_x' and `center_y' to `a_y'.
		do
			center_x := a_x
			center_y := a_y
		ensure
			set: center_x = a_x and center_y = a_y
		end

feature {NONE} -- Implementation

	link_stiffness (a_link: EG_LINK_FIGURE): REAL_64
			-- Striffness of `a_link'.
		do
			Result := 1.0
		end

invariant
	valid_electrical_repulsion: electrical_repulsion >= 0.0
	valid_stiffness: stiffness >= 0.0
	valid_center_attraction: center_attraction >= 0.0

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




end -- class EG_FORCE_DIRECTED_PHYSICS_PROPERTIES

