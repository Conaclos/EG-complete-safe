note
	description: "Arrange the nodes in a grid."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EG_GRID_LAYOUT

inherit
	EG_LAYOUT
		redefine
			default_create
		end

create
	make_with_world

feature {NONE} -- Initialization

	default_create
			-- Create a EG_GRID_LAYOUT.
		do
			Precursor {EG_LAYOUT}
			exponent := 1.0
			number_of_columns := 1
		end

feature -- Access

	point_a_x: INTEGER
			-- The x position of the start of the grid.

	point_a_y: INTEGER
			-- The y position of the start of the grid.

	point_b_x: INTEGER
			-- The x position of the end of the grid.

	point_b_y: INTEGER
			-- The y position of the end of the grid.

	grid_width: INTEGER
			-- The width of the grid.
		do
			Result := (point_b_x - point_a_x).abs
		ensure
			result_greater_equal_zero: Result >= 0
		end

	grid_height: INTEGER
			-- The height of the grid.
		do
			Result := (point_b_y - point_a_y).abs
		ensure
			result_greater_equal_zero: Result >= 0
		end

	number_of_columns: INTEGER assign set_number_of_columns
			-- Number of columns. (The number of rows is calculated
			-- such that all elements fit in the grid).

	exponent: REAL_64 assign set_exponent
			-- Exponent used to reduce grid width per level.
			-- (`grid_width' / cluster_level ^ `exponent').

feature -- Element change

	set_point_a_position (a_x, a_y: INTEGER)
			-- Set `point_a_x' to `a_x' and `point_a_y' to `a_y'.
		do
			point_a_x := a_x
			point_a_y := a_y
		ensure
			set: point_a_x = a_x and point_a_y = a_y
		end

	set_point_b_position (a_x, a_y: INTEGER)
			-- Set `point_b_x' to `a_x' and `point_b_y' to `a_y'.
		do
			point_b_x := a_x
			point_b_y := a_y
		ensure
			set: point_b_x = a_x and point_b_y = a_y
		end

	set_exponent (a_exponent: like exponent)
			-- Set `exponent' to `a_exponent'.
		do
			exponent := a_exponent
		ensure
			set: exponent = a_exponent
		end

	set_number_of_columns (a_number_of_columns: like number_of_columns)
			-- Set `number_of_columns' to `a_number_of_columns'.
		require
			a_number_of_columns_greater_zero: a_number_of_columns > 0
		do
			number_of_columns := a_number_of_columns
		ensure
			set: number_of_columns = a_number_of_columns
		end

feature {NONE} -- Implementation

	layout_linkables (a_linkables: ARRAYED_LIST [EG_LINKABLE_FIGURE]; a_level: INTEGER; a_cluster: detachable EG_CLUSTER_FIGURE)
			-- arrange `linkables'.
		local
			d_x, d_y: INTEGER
			l_start_x, l_start_y: INTEGER
			l_number_of_rows: INTEGER
			l_row, l_col: INTEGER
			l_count, i: INTEGER
			l_link: EG_LINKABLE_FIGURE
		do
			if number_of_columns = 1 then
				l_start_x := point_a_x // 2 + point_b_x // 2
				d_x := 0
			else
				d_x := ((point_b_x - point_a_x) / ((number_of_columns - 1) * a_level ^ exponent)).truncated_to_integer
				l_start_x := point_a_x
			end

			l_number_of_rows := (a_linkables.count / number_of_columns).ceiling
			if l_number_of_rows = 1 then
				l_start_y := point_a_y // 2 + point_b_y // 2
				d_y := 0
			else
				d_y := ((point_b_y - point_a_y) / ((l_number_of_rows - 1) * a_level ^ exponent)).truncated_to_integer
				d_y := d_y // a_level
				l_start_y := point_a_y
			end

			from
				l_row := 0
				i := 1
				l_count := a_linkables.count
			until
				l_row >= l_number_of_rows
			loop
				from
					l_col := 0
				until
					l_col >= number_of_columns or else i > l_count
				loop
					l_link := a_linkables.i_th (i)
					if a_level = 1 then
						l_link.set_port_position (l_start_x + l_col * d_x, l_start_y + l_row * d_y)
					else
						l_link.set_port_position (l_link.port_x + l_col * d_x, l_link.port_y + l_row * d_y)
					end
					i := i + 1
					l_col := l_col + 1
				end
				l_row := l_row + 1
			end
		end

invariant
	number_of_columns_greater_zero: number_of_columns > 0

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




end -- class EG_GRID_LAYOUT

