note
	description: "Objects that is a cluster figure that can be resized by moving one of its edges."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	EG_RESIZABLE_CLUSTER_FIGURE

inherit
	EG_CLUSTER_FIGURE
		redefine
			default_create,
			update,
			xml_node_name,
			xml_element,
			set_with_xml_element,
			recycle
		end

feature {NONE} -- Initialization

	default_create
			-- Create a EG_CLUSTER_FIGURE.
		local
			rectangle: EV_MODEL_RECTANGLE
		do
			Precursor {EG_CLUSTER_FIGURE}

			create resizer_top_left
			resizer_top_left.disable_rotating
			resizer_top_left.disable_scaling
			resizer_top_left.move_actions.extend (agent on_move_top_left)
			resizer_top_left.set_pointer_style (default_pixmaps.sizenwse_cursor)
			create rectangle.make_with_positions (0, 0, Resizers_width, Resizers_height)
			resizer_top_left.extend (rectangle)
			rectangle.hide
			extend (resizer_top_left)

			create resizer_top_right
			resizer_top_right.disable_rotating
			resizer_top_right.disable_scaling
			resizer_top_right.move_actions.extend (agent on_move_top_right)
			resizer_top_right.set_pointer_style (default_pixmaps.sizenesw_cursor)
			create rectangle.make_with_positions (- Resizers_width, 0, 0, Resizers_height)
			resizer_top_right.extend (rectangle)
			rectangle.hide
			extend (resizer_top_right)

			create resizer_bottom_right
			resizer_bottom_right.disable_rotating
			resizer_bottom_right.disable_scaling
			resizer_bottom_right.move_actions.extend (agent on_move_bottom_right)
			resizer_bottom_right.set_pointer_style (default_pixmaps.sizenwse_cursor)
			create rectangle.make_with_positions (- Resizers_width, - Resizers_height, 0, 0)
			resizer_bottom_right.extend (rectangle)
			rectangle.hide
			extend (resizer_bottom_right)

			create resizer_bottom_left
			resizer_bottom_left.disable_rotating
			resizer_bottom_left.disable_scaling
			resizer_bottom_left.move_actions.extend (agent on_move_bottom_left)
			resizer_bottom_left.set_pointer_style (default_pixmaps.sizenesw_cursor)
			create rectangle.make_with_positions (0, - Resizers_height, Resizers_width, 0)
			resizer_bottom_left.extend (rectangle)
			rectangle.hide
			extend (resizer_bottom_left)

			disable_rotating
			disable_scaling
		end

feature -- Constant

	is_user_sized_string: STRING = "IS_USER_SIZED"
			-- Xml mark representing `is_user_sized'.

	user_size_string: STRING = "USER_SIZE"
			-- Xml mark representing `user_size'.

feature -- Access

	left: INTEGER
			-- Left position.
		deferred
		end

	top: INTEGER
			-- Top position.
		deferred
		end

	right: INTEGER
			-- Right position.
		deferred
		end

	bottom: INTEGER
			-- Bottom position.
		deferred
		end

	user_size: detachable EV_RECTANGLE
			-- User resized `Current' to `user_size' if not void.

	xml_node_name: STRING
			-- <Precursor>
		do
			Result := once "EG_RESIZABLE_CLUSTER_FIGURE"
		end

	xml_element (a_node: like xml_element): XML_ELEMENT
			-- <Precursor>
		local
			l_colon: STRING
			l_user_size: like user_size
		do
			Result := Precursor {EG_CLUSTER_FIGURE} (a_node)
			l_colon := ";"
			l_user_size := user_size
			if l_user_size = Void then
				Result.put_last (Xml_routines.xml_node (Result, is_user_sized_string, boolean_representation (False)))
			else
				Result.put_last (Xml_routines.xml_node (Result, is_user_sized_string, boolean_representation (True)))
				Result.put_last (Xml_routines.xml_node (Result, user_size_string,
					l_user_size.left.out + l_colon +
					l_user_size.top.out + l_colon +
					l_user_size.width.out + l_colon +
					l_user_size.height.out + l_colon))
			end
		end

	set_with_xml_element (a_node: like xml_element)
			-- <Precursor>
		do
			Precursor {EG_CLUSTER_FIGURE} (a_node)
			if
				attached xml_routines.xml_string (a_node, user_size_string) as l_str and then
				l_str.is_boolean
			then
				user_size := rectangle_from_string (l_str)
			end
		end

feature -- Element change

	recycle
			-- <Precursor>
		do
			Precursor {EG_CLUSTER_FIGURE}
			resizer_top_left.move_actions.prune_all (agent on_move_top_left)
			resizer_top_right.move_actions.prune_all (agent on_move_top_right)
			resizer_bottom_right.move_actions.prune_all (agent on_move_bottom_right)
			resizer_bottom_left.move_actions.prune_all (agent on_move_bottom_left)
		end

	reset_user_size
			-- Set `user_size' to Void.
		do
			user_size := Void
		ensure
			set: user_size = Void
		end

feature {EG_FIGURE, EG_FIGURE_WORLD} -- Update

	update
			-- <Precursor>
		do
			resizer_top_left.set_point_position (left, top)
			resizer_top_right.set_point_position (right, top)
			resizer_bottom_right.set_point_position (right, bottom)
			resizer_bottom_left.set_point_position (left, bottom)
			is_update_required := False
		end

feature {NONE} -- Implementation

	set_top_left_position (a_x, a_y: INTEGER)
			-- Set position of top left corner to (`a_x', `a_y').
		deferred
		end

	set_bottom_right_position (a_x, a_y: INTEGER)
			-- Set position of bottom right corner to (`a_x', `a_y').
		deferred
		end

	resizer_top_left: EV_MODEL_MOVE_HANDLE
			-- Resizer for top left corner.

	resizer_top_right: EV_MODEL_MOVE_HANDLE
			-- Resizer for top right corner.

	resizer_bottom_right: EV_MODEL_MOVE_HANDLE
			-- resizer for bottom right corner.

	resizer_bottom_left: EV_MODEL_MOVE_HANDLE
			-- Resizer for bottom left corner.

	Resizers_width: INTEGER = 20
			-- Width of the resizers in pixel.

	Resizers_height: INTEGER = 20
			-- Height of the resizers in pixel.

	on_move_top_left (a_x, a_y: INTEGER; a_x_tilt, a_y_tilt, a_pressure: REAL_64; a_screen_x, a_screen_y: INTEGER)
			-- `resizer_top_left' was moved for (`a_x', `a_y').
		local
			l_new_x, l_new_y: INTEGER
		do
			l_new_x := (left + a_x).min (right)
			l_new_y := (top + a_y).min (bottom)
			set_top_left_position (l_new_x, l_new_y)
			resizer_top_left.set_point_position (l_new_x, l_new_y)
			resizer_bottom_left.set_point_position (l_new_x, resizer_bottom_left.point_y)
			resizer_top_right.set_point_position (resizer_top_right.point_x, l_new_y)
			update_user_size
			request_update
		end

	on_move_top_right (a_x, a_y: INTEGER; a_x_tilt, a_y_tilt, a_pressure: REAL_64; a_screen_x, a_screen_y: INTEGER)
			-- `resizer_top_right' was moved to (`a_x', `a_y').
		local
			l_new_x, l_new_y: INTEGER
		do
			l_new_x := (right + a_x).max (left)
			l_new_y := (top + a_y).min (bottom)
			set_top_left_position (left, l_new_y)
			set_bottom_right_position (l_new_x, bottom)
			resizer_top_right.set_point_position (l_new_x, l_new_y)
			resizer_top_left.set_point_position (resizer_top_left.point_x, l_new_y)
			resizer_bottom_right.set_point_position (l_new_x, resizer_bottom_right.point_y)
			update_user_size
			request_update
		end

	on_move_bottom_right (a_x, a_y: INTEGER; a_x_tilt, a_y_tilt, a_pressure: REAL_64; a_screen_x, a_screen_y: INTEGER)
			-- `resizer_bottom_right' was moved to (`a_x', `a_y').
		local
			l_new_x, l_new_y: INTEGER
		do
			l_new_x := (right + a_x).max (left)
			l_new_y := (bottom + a_y).max (top)
			set_bottom_right_position (l_new_x, l_new_y)
			resizer_bottom_right.set_point_position (l_new_x, l_new_y)
			resizer_top_right.set_point_position (l_new_x, resizer_top_right.point_y)
			resizer_bottom_left.set_point_position (resizer_bottom_left.point_x, l_new_y)
			update_user_size
			request_update
		end

	on_move_bottom_left (a_x, a_y: INTEGER; a_x_tilt, a_y_tilt, a_pressure: REAL_64; a_screen_x, a_screen_y: INTEGER)
			-- `resizer_bottom_left' was moved to (`a_x', `a_y').
		local
			l_new_x, l_new_y: INTEGER
		do
			l_new_x := (left + a_x).min (right)
			l_new_y := (bottom + a_y).max (top)
			set_top_left_position (l_new_x, top)
			set_bottom_right_position (right, l_new_y)
			resizer_bottom_left.set_point_position (l_new_x, l_new_y)
			resizer_top_left.set_point_position (l_new_x, resizer_top_left.point_y)
			resizer_bottom_right.set_point_position (resizer_bottom_right.point_x, l_new_y)
			update_user_size
			request_update
		end

	update_user_size
			-- Set `user_size' to current size.
		do
			if attached user_size as l_user_size then
				l_user_size.move_and_resize (left, top, right - left, bottom - top)
			else
				create user_size.make (left, top, right - left, bottom - top)
			end
		end

	rectangle_from_string (a_size: STRING): EV_RECTANGLE
		require
			a_size_not_void: a_size /= Void
		local
			strs: LIST [STRING]
			s: STRING
			l, t, w, h: INTEGER
		do
			strs := a_size.split (';')
			strs.start
			s := strs.item
			if s.is_integer then
				l := s.to_integer
			end
			strs.forth
			s := strs.item
			if s.is_integer then
				t := s.to_integer
			end
			strs.forth
			s := strs.item
			if s.is_integer then
				w := s.to_integer
			end
			strs.forth
			s := strs.item
			if s.is_integer then
				h := s.to_integer
			end
			create Result.make (l, t, w, h)
		end

invariant
	risizers_not_void: resizer_top_left /= Void and resizer_top_right /= Void and resizer_bottom_right /= Void and resizer_bottom_left /= Void

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




end -- class EG_RESIZABLE_CLUSTER_FIGURE

