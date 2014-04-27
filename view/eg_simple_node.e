note
	description: "A very simple view for a EG_NODE"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EG_SIMPLE_NODE

inherit
	EG_LINKABLE_FIGURE
		redefine
			update,
			default_create,
			xml_node_name,
			model
		end

create
	make_with_model

create {EG_LINKABLE_FIGURE}
	make_resized_from

feature {NONE} -- Initialization

	default_create
			-- Create an EG_SIMPLE_NODE.
		do
			Precursor {EG_LINKABLE_FIGURE}
			create node_figure.make_with_positions (-figure_size // 2, -figure_size // 2, figure_size // 2, figure_size // 2)
			node_figure.set_background_color (color)
			extend (node_figure)
			set_center
		end

	make_with_model (a_model: like model)
			-- Create a EG_SIMPLE_NODE using `a_model'.
		require
			a_model_not_void: a_model /= Void
		do
			create node_figure

			model := a_model
			default_create
			initialize
			update
		end

	make_resized_from (a_other: like Current; n: INTEGER)
			-- Create a EG_SIMPLE_NODE using `a_other'
			-- and resize the freshly created area with a count of `n'.
		do
			make_with_model (a_other.model)
			area_v2 := area_v2.resized_area (n)
		ensure
			same_model: model = a_other.model
			area_count: area_v2.count = n
		end

feature -- Access

	model: EG_NODE
			-- <Precursor>

	port_x: INTEGER
			-- <Precursor>
		do
			Result := point_x
		end

	port_y: INTEGER
			-- <Precursor>
		do
			Result := point_y
		end

	size: EV_RECTANGLE
			-- <Precursor>
		do
			Result := node_figure.bounding_box
		end

	height: INTEGER
			-- <Precursor>
		do
			Result := node_figure.radius2 * 2
		end

	width: INTEGER
			-- <Precursor>
		do
			Result := node_figure.radius1 * 2
		end

	xml_node_name: STRING
			-- <Precursor>
		do
			Result := "EG_SIMPLE_NODE"
		end

feature -- Element change

	update_edge_point (p: EV_COORDINATE; a_angle: REAL_64)
			-- Set `p' position such that it is on a point on the edge of `Current'.
		local
			l_x, l_y, l: REAL_64
			a, b: INTEGER
		do
				-- Some explanation for those you have forgotten about their math classes.
				-- We have two equations:
				-- 1 - the ellipse: x^2/a^2 + y^2/b^2 = 1
				-- 2 - the line which has an angle `a_angle': y = tan(an_angle) * x
				--
				-- The solution of the problem is to find the point (x, y) which is
				-- common to both equations (1) and (2). Because `tangent' only applies for
				-- angle values between ]-pi / 2, pi / 2 [, we have to get the result
				-- for the other quadrant of the ellipse by mirroring the value of x
				-- and of y.
				-- With `l = tan(a_angle)', we can write the following equivalences:
				-- x^2/a^2 + y^2/b^2 = 1 <=> x^2/a^2 + (l^2*x^2)/b^2 = 1
				-- x^2/a^2 + y^2/b^2 = 1 <=> x^2*b^2 + l^2*x^2*a^2 = a^2*b^2
				-- x^2/a^2 + y^2/b^2 = 1 <=> x^2*(b^2 + l^2*a^2) = a^2*b^2
				-- x^2/a^2 + y^2/b^2 = 1 <=> x^2 = a^2*b^2 / (b^2 + l^2*a^2)
				-- x^2/a^2 + y^2/b^2 = 1 <=> x = a*b / sqrt(b^2 + l^2*a^2)
			l := tangent (a_angle)
			a := node_figure.radius1
			b := node_figure.radius2
			if a = 0 and b = 0 then
				l_x := 0
				l_y := 0
			else
				l_x := (a * b) / sqrt (b^2 + l^2 * a^2)
				l_y := l * l_x

				if cosine (a_angle) < 0 then
						-- When we are in ]pi/2, 3*pi/2[, then we need to reverse
						-- the coordinates. It looks strange like that, but don't forget
						-- that although `l_x' is always positive, `l_y' might be negative depending
						-- on the sign of `l'. This is why we need to reverse both coordinates,
						-- but because we also need to reverse the `l_y' value because in a figure world
						-- the `l_y' coordinates go down and not up, the effect is null, thus no operation
						-- on `l_y'.
					l_x := - l_x
				else
						-- We need to reverse the y value, because in a figure world, the y coordinates
						-- go down and not up.
					l_y := - l_y
				end
			end
			p.set_precise (port_x + l_x, port_y - l_y)
		end

feature {EG_FIGURE, EG_FIGURE_WORLD} -- Update

	update
			-- <Precursor>
		do
			if is_label_shown then
				name_label.set_point_position (point_x + figure_size // 2, point_y + figure_size // 2)
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
					node_figure.set_line_width (node_figure.line_width * 2)
				else
					node_figure.set_line_width (node_figure.line_width // 2)
				end
			end
		end

	figure_size: INTEGER
			-- Size of figure in pixel.
		do
			Result := 20
		end

	color: EV_COLOR
			-- Color of figure.
		once
			create Result.make_with_rgb (1,0,0)
		ensure
			result_not_void: Result /= Void
		end

	node_figure: EV_MODEL_ELLIPSE
			-- The figure visualizing `Current'.

	number_of_figures: INTEGER = 2
			-- <Precursor>
			-- (`name_label' and `node_figure').

	new_filled_list (n: INTEGER): like Current
			-- <Precursor>
		do
			create Result.make_resized_from (Current, n)
		end

invariant
	node_figure_not_void: node_figure /= Void

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




end -- class EG_SIMPLE_NODE

