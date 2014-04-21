note
	description: "EG_CIRCLE_LAYOUT arranges the nodes in a circle around a center with a radius."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EG_CIRCLE_LAYOUT

inherit
	EG_LAYOUT
		redefine
			default_create
		end

	EV_MODEL_DOUBLE_MATH
		undefine
			default_create
		end

create
	make_with_world

feature {NONE} -- Initialization

	default_create
			-- Create a EG_CIRCLE_LAYOUT.
		do
			Precursor {EG_LAYOUT}
			exponent := 1.0
		end

feature -- Access

	center_x: INTEGER
				-- X position of the center of the circle.

	center_y: INTEGER
				-- Y position of the center of the circle.

	radius: INTEGER assign set_radius
				-- Radius of largest circle.

	exponent: REAL_64 assign set_exponent
				-- Exponent used to reduce radius per level:
				-- (`radius' / cluster_level ^ `exponent').

feature -- Element change

	set_center (a_x, a_y: like center_x)
			-- Set `center_x' to `a_x' and `center_y' to `a_y'.
		do
			center_x := a_x
			center_y := a_y
		ensure
			set: center_x = a_x and center_y = a_y
		end

	set_radius (a_radius: like radius)
			-- Set `radius' to `a_radius'.
		require
			a_radius_larger_zero: a_radius > 0
		do
			radius := a_radius
		ensure
			set: radius = a_radius
		end

	set_exponent (a_exponent: like exponent)
			-- Set `exponent' to `a_exponent'.
		require
			a_exponent_larger_equal_one: a_exponent >= 1.0
		do
			exponent := a_exponent
		ensure
			set: exponent = a_exponent
		end

feature {NONE} -- Implementation

	layout_linkables (a_linkables: ARRAYED_LIST [EG_LINKABLE_FIGURE]; a_level: INTEGER; a_cluster: detachable EG_CLUSTER_FIGURE)
			-- arrange `a_linkables'.
		local
			l_count: INTEGER
			l_level_radius: REAL_64
			d_angle, angle: REAL_64
		do
			l_count := a_linkables.count
			if l_count = 1 then
				l_level_radius := 0
			else
				l_level_radius := (1 / a_level ^ exponent) * radius
				d_angle := 2 * pi / l_count
			end

			across
				a_linkables as it
			loop
				if a_level = 1 then
					it.item.set_port_position ((cosine (angle) * l_level_radius).truncated_to_integer + center_x, (sine (angle) * l_level_radius).truncated_to_integer + center_y)
				elseif attached it.item.cluster as l_cluster then
					it.item.set_port_position ((cosine (angle) * l_level_radius).truncated_to_integer + l_cluster.port_x, (sine (angle) * l_level_radius).truncated_to_integer + l_cluster.port_y)
				end
				angle := angle + d_angle
			end
		end

invariant
	exponent_larger_equal_one: exponent >= 1.0
	radius_larger_zero: radius > 0

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




end -- class EG_CIRCLE_LAYOUT

