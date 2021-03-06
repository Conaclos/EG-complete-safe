note
	description: "[

					A polyline connecting source and target. The user can
					add new points by clicking on the line and can move
					points on the line around.
			]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EG_POLYLINE_LINK_FIGURE

inherit
	EG_LINK_FIGURE
		redefine
			default_create,
			initialize,
			xml_element,
			xml_node_name,
			set_with_xml_element,
			recycle
		end

create
	make

create {EG_POLYLINE_LINK_FIGURE}
	make_resized_from

feature {NONE} -- Initialization

	default_create
			-- Create a EG_POLYLINE_LINK_FIGURE without dimension.
		do
			create edge_move_handlers.make (0)
			create line

			Precursor {EG_LINK_FIGURE}

			line.extend_point (create {EV_COORDINATE})
			line.extend_point (create {EV_COORDINATE})
			extend (line)

			disable_moving
			disable_rotating
			disable_scaling

			reflexive_radius := 50
		end

	make (a_model: like model; a_source, a_target: like source)
			-- Make a polyline link using `a_model', `a_source' and `a_target'.
		require
			a_model_not_void: a_model /= Void
		do
			model := a_model
			source := a_source
			target := a_target
			default_create
			initialize
		ensure
			model_set: model = a_model
			source_set: source = a_source
			target_set: target = a_target
		end

	initialize
			-- <Precursor>
		do
			Precursor {EG_LINK_FIGURE}
			if model.is_reflexive then
				line.set_point_count (4)
			else
				line.pointer_button_press_actions.extend (agent pointer_button_pressed_on_a_line)
				line.set_pointer_style (new_edge_cursor)
			end
			if model.is_directed then
				line.enable_end_arrow
			end
		end

	make_resized_from (a_other: like Current; n: INTEGER)
			-- Make a polyline link using `a_other'
			-- and resize the freshly created area with a count of `n'.
		do
			make (a_other.model, a_other.source, a_other.target)
			area_v2 := area_v2.resized_area (n)
		ensure
			same_model: model = a_other.model
			same_source_and_target: source = a_other.source and target = a_other.target
			area_count: area_v2.count = n
		end

feature -- Constant

	edge_string: STRING = "EDGE"
			-- Xml mark representing edge.

	x_pos_string: STRING = "X_POS"
			-- Xml mark representing x position.

	y_pos_string: STRING = "Y_POS"
			-- Xml mark representing y position.

	line_width_string: STRING = "LINE_WIDTH"
			-- Xml mark representing `line_width'.

	line_color_string: STRING = "LINE_COLOR"
			-- Xml mark representing `line_color'.

feature -- Access

	start_point_x: INTEGER
			-- x position of the first point.
		do
			Result := line.point_array.item (0).x
		end

	start_point_y: INTEGER
			-- y position of the first point.
		do
			Result := line.point_array.item (0).y
		end

	end_point_x: INTEGER
			-- x position of the last point.
		do
			Result := line.point_array.item (line.point_array.count - 1).x
		end

	end_point_y: INTEGER
			-- y position of the last point.
		do
			Result := line.point_array.item (line.point_array.count - 1).y
		end

	i_th_point_x (i: INTEGER): INTEGER
			-- x position of `i'-th point.
		do
			Result := line.i_th_point_x (i)
		end

	i_th_point_y (i: INTEGER): INTEGER
			-- y position of `i'-th point.
		do
			Result := line.i_th_point_y (i)
		end

	line_width: INTEGER
			-- Line width.
		do
			Result := line.line_width
		end

	edges_count: INTEGER
			-- Edges count.
		do
			Result := edge_move_handlers.count
		end

	foreground_color: EV_COLOR
			-- Foreground color.
		do
			Result := line.foreground_color
		end

	xml_element (a_node: like xml_element): XML_ELEMENT
			-- <Precursor>
		local
			l_edge_xml_element, l_edges: like xml_element
			l_item: EV_COORDINATE
			l_x_pos_string: STRING
			l_y_pos_string: STRING
			l_xml_routines: like xml_routines
			l_xml_namespace: like xml_namespace
			l_foreground_color: like foreground_color
		do
			l_foreground_color := foreground_color
			l_x_pos_string := x_pos_string
			l_y_pos_string := y_pos_string
			l_xml_routines := xml_routines
			l_xml_namespace := xml_namespace
			Result := Precursor {EG_LINK_FIGURE} (a_node)
			create l_edges.make (Result, once "EDGES", xml_namespace)

			across
				line.point_array as it
			loop
				l_item := it.item
				create l_edge_xml_element.make (l_edges, edge_string, l_xml_namespace)
				l_edge_xml_element.put_last (l_xml_routines.xml_node (l_edge_xml_element, l_x_pos_string, l_item.x.out))
				l_edge_xml_element.put_last (l_xml_routines.xml_node (l_edge_xml_element, l_y_pos_string, l_item.y.out))
				l_edges.put_last (l_edge_xml_element)
			end

			Result.put_last (l_edges)
			Result.put_last (l_xml_routines.xml_node (Result, line_width_string, line_width.out))
			Result.put_last (l_xml_routines.xml_node (Result, line_color_string,
				l_foreground_color.red_8_bit.out + ";" +
				l_foreground_color.green_8_bit.out + ";" +
				l_foreground_color.blue_8_bit.out))
		end

	set_with_xml_element (a_node: like xml_element)
			-- <Precursor>
		local
			l_cursor: XML_COMPOSITE_CURSOR
			l_x, l_y: INTEGER
			l_x_pos_string, l_y_pos_string: STRING
			l_xml_routines: like xml_routines
			l_edges_count: INTEGER
		do
			Precursor {EG_LINK_FIGURE} (a_node)
			l_x_pos_string := x_pos_string
			l_y_pos_string := y_pos_string
			l_xml_routines := xml_routines

			reset
			if
				attached {like xml_element} a_node.item_for_iteration as edges
				and then attached source as l_source
				and then attached target as l_target
			then
				a_node.forth
				l_cursor := edges.new_cursor
				l_cursor.start
				line.point_array.item (0).set (l_source.port_x, l_source.port_y)

				if is_reflexive then
					if not l_cursor.after then
						if attached {like xml_element} l_cursor.item as l_item then
							l_item.start
							l_x := l_xml_routines.xml_integer (l_item, l_x_pos_string)
							l_y := l_xml_routines.xml_integer (l_item, l_y_pos_string)
							line.point_array.item (1).set (l_x, l_y)
						end
						l_cursor.forth
						if attached {like xml_element} l_cursor.item as l_item then
							l_item.start
							l_x := l_xml_routines.xml_integer (l_item, l_x_pos_string)
							l_y := l_xml_routines.xml_integer (l_item, l_y_pos_string)
							line.point_array.item (2).set (l_x, l_y)
						end
					end
				else
					from
					until
						l_cursor.after
					loop
						if attached {like xml_element} l_cursor.item as l_item then
							l_item.start
							l_edges_count := edges_count
							add_point_between (l_edges_count + 1, l_edges_count + 2)
							l_x := l_xml_routines.xml_integer (l_item, l_x_pos_string)
							l_y := l_xml_routines.xml_integer (l_item, l_y_pos_string)
							l_edges_count := edges_count
							set_i_th_point_position (l_edges_count + 1, l_x, l_y)
						end
						l_cursor.forth
					end
				end
				line.point_array.item (line.point_array.count - 1).set (l_target.port_x, l_target.port_y)
				set_line_width (l_xml_routines.xml_integer (a_node, once "LINE_WIDTH"))
				set_foreground_color (l_xml_routines.xml_color (a_node, once "LINE_COLOR"))
			end
		end

	xml_node_name: STRING
			-- <Precursor>
		do
			Result := "EG_POLYLINE_LINK_FIGURE"
		end

feature -- Status report

	is_start_arrow: BOOLEAN
			-- Is start arrow?
		do
			Result := line.is_start_arrow
		end

	is_end_arrow: BOOLEAN
			-- Is end arrow?
		do
			Result := line.is_end_arrow
		end

feature -- Status settings

	enable_end_arrow
			-- Set `is_end_arrow' `True'.
		do
			line.enable_end_arrow
			request_update
		end

	enable_start_arrow
			-- Set `is_start_arrow' `True'.
		do
			line.enable_start_arrow
			request_update
		end

feature -- Element change

	recycle
			-- <Precursor>
		do
			Precursor {EG_LINK_FIGURE}
			line.pointer_button_press_actions.prune_all (agent pointer_button_pressed_on_a_line)
		end

	set_line_width (a_line_width: like line_width)
			-- Set `line_width' to `a_line_width'.
		require
			a_line_width_positive: a_line_width > 0
		do
			line.set_line_width (a_line_width)
			request_update
		ensure
			set: line_width = a_line_width
		end

	set_foreground_color (a_color: EV_COLOR)
			-- Set `foreground_color' to `a_color'.
		require
			a_color_not_void: a_color /= Void
		do
			line.set_foreground_color (a_color)
			request_update
		ensure
			set: foreground_color = a_color
		end

	set_i_th_point_position (i: INTEGER; a_x, a_y: INTEGER)
			-- Set position of `i'-th point to (`a_x', `a_y').
		require
			valid_index: 1 < i and i < edges_count + 2
		do
			line.set_i_th_point_position (i, a_x, a_y)
			edge_move_handlers.i_th (i - 1).set_point_position (a_x, a_y)
			request_update
		ensure
			set: i_th_point_x (i) = a_x and i_th_point_y (i) = a_y
		end

	add_point_between (i, j: INTEGER)
			-- Add a point between `i'-th and `j'-th point.
		require
			j_equals_i_plus_one: j = i + 1
			in_range: i >= 1 and j <= edges_count + 2
		local
			l_point_array: like point_array
			n: INTEGER
			mh: EG_EDGE
			new_x, new_y: INTEGER
			new_point: EV_COORDINATE
		do
			line.set_point_count (line.point_count + 1)
			l_point_array := line.point_array
			from
				n := l_point_array.count - 1
			until
				n < j
			loop
				l_point_array.put (l_point_array.item (n - 1), n)
				n := n - 1
			end
			check
				j_th_equals_j_plus_one_th: l_point_array.item (j) = l_point_array.item (j - 1)
			end

			new_x := as_integer (line.i_th_point_x (i) / 2 + line.i_th_point_x (j) / 2)
			new_y := as_integer (line.i_th_point_y (i) / 2 + line.i_th_point_y (j) / 2)

			create new_point.make (new_x, new_y)
			l_point_array.put (new_point , j - 1)

			create mh.make (Current)
			mh.set_point_position (new_x, new_y)
			mh.set_corresponding_point (new_point)
			if edge_move_handlers.is_empty then
				edge_move_handlers.extend (mh)
			elseif i = 1 then
				edge_move_handlers.put_front (mh)
			else
				edge_move_handlers.go_i_th (i - 1)
				edge_move_handlers.put_right (mh)
			end
			mh.move_actions.extend (agent edge_moved (new_point, ?, ?, ?, ?, ?, ?, ?))
			mh.start_actions.extend (agent edge_start (mh))
			mh.end_actions.extend (agent edge_end (mh))
			extend (mh)
			invalidate
			request_update
		ensure
			one_added: old line.point_count + 1 = line.point_count
			j_now_j_plus_one: old (line).i_th_point_x (j) = line.i_th_point_x (j + 1) and old (line).i_th_point_y (j) = line.i_th_point_y (j + 1)			j_th_edge_move_handler_at_j_th_x_position: edge_move_handlers.i_th (i).point_x = i_th_point_x (i + 1)
			j_th_edge_move_handler_at_j_th_y_position: edge_move_handlers.i_th (i).point_y = i_th_point_y (i + 1)
		end

	remove_i_th_point (i: INTEGER)
			-- Remove `i'-th point.
		require
			valid_index: i > 1 and i < edges_count + 2
		local
			l_point_array: like point_array
			n, m, nb: INTEGER
			l_item: EG_EDGE
		do
			l_point_array := line.point_array
			from
				n := 0
				m := 0
				nb := l_point_array.count
			until
				n >= nb
			loop
				if n /= (i - 1) then
					l_point_array.put (l_point_array.item (n), m)
					m := m + 1
				end
				n := n + 1
			end
			line.set_point_count (line.point_count - 1)
			-- remove the handle
			edge_move_handlers.go_i_th (i - 1)
			l_item := edge_move_handlers.item
			edge_move_handlers.remove
			prune_all (l_item)
			request_update
		ensure
			one_point_less: old (line).point_count = line.point_count + 1
			one_edge_move_hadler_less: old (edge_move_handlers).count = edge_move_handlers.count + 1
		end

	reset
			-- Remove all edges.
		local
			last_point: EV_COORDINATE
		do
			if not is_reflexive then
				across
					edge_move_handlers as it
				loop
					start
					search (it.item)
					if not exhausted then
						remove
					end
				end
				edge_move_handlers.wipe_out
				last_point := line.point_array.item (line.point_array.count - 1)
				line.set_point_count (1)
				line.extend_point (last_point)
				line.point_array.put (last_point, line.point_array.count - 1)
				request_update
			end
		end

feature {EG_FIGURE, EG_FIGURE_WORLD} -- Update

	update
			-- <Precursor>
		local
			nx, ny: INTEGER
		do
			if not model.is_reflexive then
				if edge_move_handlers.is_empty then
					set_end_and_start_point_to_edge
				else
					set_start_point_to_edge
					set_end_point_to_edge
				end
			else
				nx := source.port_x
				ny := source.port_y
				if nx /= line.i_th_point_x (1) or ny /= line.i_th_point_y (1) then
					line.set_i_th_point_position (1, nx, ny)
					line.set_i_th_point_position (line.point_count, nx, ny)
					line.set_i_th_point_position (2, nx + 150, ny - 50)
					line.set_i_th_point_position (3, nx + 150, ny + 50)
					set_start_point_to_edge
					set_end_point_to_edge
					line.set_i_th_point_position (2, line.i_th_point_x (1) + reflexive_radius, line.i_th_point_y (1) - as_integer (reflexive_radius / 3))
					line.set_i_th_point_position (3, line.i_th_point_x (4) + reflexive_radius, line.i_th_point_y (4) + as_integer (reflexive_radius / 3))
				end
			end
			invalidate
			center_invalidate
			is_update_required := False
		end

	reflexive_radius: INTEGER
			-- Radius of reflexive link.

feature {NONE} -- Implementation

	set_is_selected (a_is_selected: like is_selected)
			-- <Precursor>
		do
			if is_selected /= a_is_selected then
				is_selected := a_is_selected
				if a_is_selected then
					line.set_line_width (line.line_width * 2)
				else
					line.set_line_width (line.line_width // 2)
				end
			end
		end

	edge_moved (a_point: EV_COORDINATE; a_x, a_y: INTEGER; a_x_tilt, a_y_tilt, a_pressure: REAL_64; a_screen_x, a_screen_y: INTEGER)
			-- `a_point' was moved for `a_x', `a_y'.
		do
			a_point.set_precise (a_point.x_precise + a_x, a_point.y_precise + a_y)
			request_update
		end

	edge_start (a_edge: EG_EDGE)
			-- User starts to move `a_edge'.
		require
			an_edge_not_void: a_edge /= Void
		do
		end

	edge_end (a_edge: EG_EDGE)
			-- User ends to move `a_edge'.
		require
			an_edge_not_void: a_edge /= Void
		do
		end

	set_start_point_to_edge
			-- Set the start point such that it is element of the edge of the source figure.
		local
			l_angle: REAL_64
			l_pa: like point_array
			p1: EV_COORDINATE
		do
			l_pa := line.point_array
			p1 := l_pa.item (1)
			l_angle := line_angle (source.port_x, source.port_y, p1.x_precise, p1.y_precise)
			source.update_edge_point (l_pa.item (0), l_angle)
		end

	set_end_point_to_edge
			-- Set the end point such that it is element of the edge of the target figure.
		local
			l_angle: REAL_64
			l_count: INTEGER
			l_pa: like point_array
			p: EV_COORDINATE
		do
			l_pa := line.point_array
			l_count := l_pa.count
			p := l_pa.item (l_count - 2)
			l_angle := line_angle (target.port_x, target.port_y, p.x_precise, p.y_precise)
			target.update_edge_point (l_pa.item (l_count - 1), l_angle)
		end

	set_end_and_start_point_to_edge
			-- Set end and start point on the edge of source and target.
		require
			no_edges: edges_count = 0
		local
			l_angle: REAL_64
			l_point_array: like point_array
		do
			l_point_array := line.point_array
			l_angle := line_angle (source.port_x, source.port_y, target.port_x, target.port_y)
			source.update_edge_point (l_point_array.item (0), l_angle)
			l_angle := pi + l_angle
			source.update_edge_point (l_point_array.item (1), l_angle)
		end

	pointer_button_pressed_on_a_line (a_x, a_y, a_button: INTEGER; a_x_tilt, a_y_tilt, a_pressure: REAL_64; a_screen_x, a_screen_y: INTEGER)
			-- User pressed on `line'.
		local
			i, nb: INTEGER
			l_point_array: like point_array
			point_found: BOOLEAN
			lw: INTEGER
			p, q: EV_COORDINATE
			new_handler: EG_EDGE
		do
			if a_button = 1 and not is_on_edge (a_x, a_y) and source /= target then
				from
					l_point_array := line.point_array
					point_found := False
					i := 0
					nb := l_point_array.count - 2
					lw := line_width.max (6)
				until
					point_found or else i > nb
				loop
					p := l_point_array.item (i)
					q := l_point_array.item (i + 1)
					point_found := point_on_segment (a_x, a_y, p.x_precise, p.y_precise, q.x_precise, q.y_precise, lw)
					i := i + 1
				end
				if point_found then
					add_point_between (i, i + 1)
					new_handler := edge_move_handlers.i_th (i)
					set_i_th_point_position (i + 1, a_x, a_y)
					new_handler.show
					new_handler.on_start_resizing (a_x, a_y, a_button, a_x_tilt, a_y_tilt, a_pressure, a_screen_x, a_screen_y)
					check
						new_handle_at_ax_ay: edge_move_handlers.i_th (i).point_x = a_x and edge_move_handlers.i_th (i).point_y = a_y
					end
				end
			end
		end

	new_edge_cursor: EV_POINTER_STYLE
			-- Cursor displayed when pointer over a line (white dot).
		local
			pix_map: EV_PIXMAP
		once
			create pix_map.make_with_size (10, 10)
			pix_map.set_foreground_color (create {EV_COLOR}.make_with_rgb (1, 1, 1))
			pix_map.fill_ellipse (0, 0, pix_map.width, pix_map.height)
			pix_map.set_foreground_color (create {EV_COLOR}.make_with_rgb (0, 0, 0))
			pix_map.draw_ellipse (0, 0, pix_map.width, pix_map.height)
			create Result.make_with_pixmap (pix_map, pix_map.width // 2, pix_map.height // 2)
		end

	is_on_edge (a_x, a_y: INTEGER): BOOLEAN
			-- is position `a_x', `a_y' on an edge?
		do
			Result := across edge_move_handlers as it some it.item.first.position_on_figure (a_x, a_y) end
		end

	on_is_directed_change
			-- <Precursor>
		do
			if model.is_directed then
				line.enable_end_arrow
			else
				line.disable_end_arrow
			end
			request_update
		end

	line: EV_MODEL_POLYLINE
			-- The polyline visualizing the link.

	new_filled_list (n: INTEGER): like Current
			-- <Precursor>
		do
			create Result.make_resized_from (Current, n)
		end

feature {EG_FIGURE_WORLD} -- Implementation

	edge_move_handlers: ARRAYED_LIST [EG_EDGE]
			-- Move handlers for the edges of the polyline.
			-- start_point and end_point have no move_handlers.

invariant
	reflexive_radius_not_negative: reflexive_radius >= 0
	edge_move_handlers_exists: edge_move_handlers /= Void
	line_not_void: line /= Void

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

end -- class EG_POLYLINE_LINK_FIGURE

