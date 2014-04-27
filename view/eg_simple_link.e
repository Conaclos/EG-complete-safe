note
	description: "A very simple implementation for a EG_LINK_FIGURE"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EG_SIMPLE_LINK

inherit
	EG_LINK_FIGURE
		redefine
			default_create,
			xml_node_name
		end

create
	make

create {EG_LINK_FIGURE}
	make_resized_from

feature {NONE} -- Initialization

	default_create
			-- Create an EG_SIMPLE_LINK.
		do
			create reflexive.make_with_positions (0, 0, 10, 10)
			create line
			Precursor {EG_LINK_FIGURE}
			extend (line)
		end

	make (a_model: EG_LINK; a_source, a_target: like source)
			-- Make a link using `a_model'.
		require
			a_model_not_void: a_model /= Void
		do
			model := a_model
			source := a_source
			target := a_target
			default_create
			initialize

			if a_model.is_directed then
				line.enable_end_arrow
			end
			if a_model.is_reflexive then
				prune_all (line)
				extend (reflexive)
			end

			disable_moving
			disable_scaling
			disable_rotating

			update
		ensure
			model_set: model = a_model
			source_set: source = a_source
			target_set: target = a_target
		end

	make_resized_from (a_other: like Current; n: INTEGER)
			-- Make a link using `a_other'
			-- and resize the freshly created area with a count of `n'.
		do
			make (a_other.model, a_other.source, a_other.target)
			area_v2 := area_v2.resized_area (n)
		ensure
			same_model: model = a_other.model
			same_source_and_target: source = a_other.source and target = a_other.target
			area_count: area_v2.count = n
		end

feature -- Access

	xml_node_name: STRING
			-- <Precursor>
		do
			Result := "EG_SIMPLE_LINK"
		end

	arrow_size: INTEGER assign set_arrow_size
			-- Size of the arrow.
		do
			Result := line.arrow_size
		end

feature -- Element change

	set_arrow_size (i: like arrow_size)
			-- Set `arrow_size' to `i'.
		require
			i_positive: i > 0
		do
			line.set_arrow_size (i)
		ensure
			set: arrow_size = i
		end

feature {EG_FIGURE, EG_FIGURE_WORLD} -- Update

	update
			-- <Precursor>
		local
			p1, p2: EV_COORDINATE
			l_angle: REAL_64
			source_size: EV_RECTANGLE
		do
			if not model.is_reflexive then
				p1 := line.point_array.item (0)
				p1.set (source.port_x, source.port_y)

				p2 := line.point_array.item (1)
				p2.set (target.port_x, target.port_y)

				l_angle := line_angle (p1.x_precise, p1.y_precise, p2.x_precise, p2.y_precise)
				source.update_edge_point (p1, l_angle)
				l_angle := pi + l_angle
				target.update_edge_point (p2, l_angle)

				line.invalidate
				line.center_invalidate
				if is_label_shown then
					name_label.set_point_position (line.x, line.y)
				end
			else
				source_size := source.size
				reflexive.set_x_y (source_size.right + reflexive.radius1, source_size.top + source_size.height // 2)
				if is_label_shown then
					name_label.set_point_position (reflexive.x + reflexive.radius1, reflexive.y)
				end
			end
			is_update_required := False
		end

feature {NONE} -- Implementation

	set_is_selected (a_is_selected: like is_selected)
			-- <Precursor>
		do
			is_selected := a_is_selected
		end

	line: EV_MODEL_LINE
			-- The line representing the link.

	reflexive: EV_MODEL_ELLIPSE
			-- The ellipse used when link `is_reflexive'.

	on_is_directed_change
			-- <Precursor>
		do
			if model.is_directed then
				line.enable_end_arrow
			else
				line.disable_end_arrow
			end
			line.invalidate
			line.center_invalidate
		end

	new_filled_list (n: INTEGER): like Current
			-- <Precursor>
		do
			create Result.make_resized_from (Current, n)
		end

invariant
	line_not_void: line /= Void
	reflexive_not_void: reflexive /= Void
	arrow_size_positive: arrow_size > 0

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




end -- class EG_SIMPLE_LINK

