note
	description: "A very simple implementation of a EG_CLUSTER_FIGURE."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EG_SIMPLE_CLUSTER

inherit
	EG_CLUSTER_FIGURE
		redefine
			default_create,
			update,
			xml_node_name
		end

create
	make_with_model

feature {NONE} -- Initialization

	default_create
			-- Create an empty cluster.
		do
			Precursor {EG_CLUSTER_FIGURE}
			rectangle.enable_dashed_line_style
			extend (rectangle)
		end

	make_with_model (a_model: EG_CLUSTER)
			-- Create a cluster using `a_model'.
		require
			a_model_not_void: a_model /= Void
		do
			create rectangle
			model := a_model

			default_create
			initialize

			disable_rotating
			disable_scaling

			update
		end

feature -- Access

	port_x: INTEGER
			-- <Precursor>
		do
			Result := rectangle.x
		end

	port_y: INTEGER
			-- <Precursor>
		do
			Result := rectangle.y
		end

	size: EV_RECTANGLE
			-- <Precursor>
		do
			Result := rectangle.bounding_box
		end

	height: INTEGER
			-- <Precursor>
		do
			Result := rectangle.height
		end

	width: INTEGER
			-- <Precursor>
		do
			Result := rectangle.width
		end

	xml_node_name: STRING
			-- <Precursor>
		do
			Result := "EG_SIMPLE_CLUSTER"
		end


feature -- Element change

	update_edge_point (p: EV_COORDINATE; a_angle: REAL_64)
			-- Set `p' position such that it is on a point on the edge of `Current'.
		local
			m: REAL_64
			l_new_x, l_new_y: REAL_64
			l_mod_angle: REAL_64
			l_pi, l_pi2: REAL_64
			l_right, l_left, l_bottom, l_top: INTEGER
		do
			l_left := rectangle.point_a_x
			l_top := rectangle.point_a_y
			l_right := rectangle.point_b_x
			l_bottom := rectangle.point_b_y
			l_pi := pi
			l_pi2 := l_pi / 2
			l_mod_angle := modulo (a_angle, 2 * l_pi)

			if l_mod_angle = 0 then
				l_new_x := l_right
				l_new_y := port_y
			elseif l_mod_angle = l_pi2 then
				l_new_x := port_x
				l_new_y := l_bottom
			elseif l_mod_angle = l_pi then
				l_new_x := l_left
				l_new_y := port_y
			elseif l_mod_angle = 3 * l_pi2 then
				l_new_x := port_x
				l_new_y := l_top
			else
				m := tangent (l_mod_angle)
				check
					m_never_zero: m /= 0.0
				end
				l_new_x := (l_bottom + m * port_x - port_y) / m

				if l_new_x > l_left and l_new_x < l_right then
					if l_mod_angle > 0 and l_mod_angle < l_pi then
						-- intersect with bottom line
						l_new_y := l_bottom
					else
						-- intersect with top line
						l_new_y := l_top
						l_new_x := 2 * port_x - l_new_x
					end
				else
					l_new_y := m * l_right - m * port_x + port_y
					if l_mod_angle > l_pi2 and l_mod_angle < 3 * l_pi2 then
						-- intersect with left line
						l_new_x := l_left
						l_new_y := 2 * port_y - l_new_y
					else
						-- intersect with right line
						l_new_x := l_right
					end
				end
			end
			p.set_precise (l_new_x, l_new_y)
		end

feature {EG_FIGURE, EG_FIGURE_WORLD} -- Update

	update
			-- <Precursor>
		local
			l_min_size: like minimum_size
		do
			l_min_size := minimum_size
			rectangle.set_point_a_position (l_min_size.left, l_min_size.top)
			rectangle.set_point_b_position (l_min_size.right, l_min_size.bottom)
			if is_label_shown then
				name_label.set_point_position (rectangle.point_a_x, rectangle.point_a_y - name_label.height)
			end
			is_update_required := False
		end

feature {NONE} -- Implementation

	set_is_selected (a_is_selected: like is_selected)
			-- <Precursor>
		do
			if is_selected /= a_is_selected then
				is_selected := a_is_selected
				if a_is_selected then
					rectangle.set_line_width (rectangle.line_width * 2)
				else
					rectangle.set_line_width (rectangle.line_width // 2)
				end
			end
		end

	rectangle: EV_MODEL_RECTANGLE
			-- The rectangle visualising the border of `Current'.

	number_of_figures: INTEGER = 2
			-- <Precursor>
			-- (`name_label' and `rectangle').

feature {NONE} -- Obsolete

	new_filled_list (n: INTEGER): like Current
			-- <Precursor>
		do
			check not_implemented: False then end
		end

invariant
	rectangle_not_void: rectangle /= Void

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




end -- class EG_SIMPLE_CLUSTER

