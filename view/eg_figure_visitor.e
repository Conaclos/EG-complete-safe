note
	description: "Visitors for EG_FIGURE."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	EG_FIGURE_VISITOR

feature -- Visiting

	process_figure_world (a_figure_world: EG_FIGURE_WORLD)
			-- Process `a_figure_world'.
		require
			a_figure_world_attached: a_figure_world /= Void
		deferred
		end

	process_figure (a_figure: EG_FIGURE)
			-- Process `a_figure'.
		require
			a_figure_attached: a_figure /= Void
		deferred
		end

	process_linkable_figure (a_linkable_figure: EG_LINKABLE_FIGURE)
			-- Process `a_linkable_figure'.
		require
			l_linkable_figure_attached: a_linkable_figure /= Void
		deferred
		end

	process_link_figure (a_link_figure: EG_LINK_FIGURE)
			-- Process `a_link_figure'.
		require
			l_link_figure_attached: a_link_figure /= Void
		deferred
		end

	process_cluster_figure (a_cluster_figure: EG_CLUSTER_FIGURE)
			-- Process `a_cluster_figure'.
		require
			a_cluster_figure_attached: a_cluster_figure /= Void
		deferred
		end

note
	copyright: "Copyright (c) 1984-2014, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
