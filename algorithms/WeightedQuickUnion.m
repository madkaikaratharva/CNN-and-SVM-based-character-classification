classdef WeightedQuickUnion < handle
    properties
        n; data;
    end

    methods
        function obj = WeightedQuickUnion(n)
            obj.n = n;
            obj.data = -1 * ones(1, n);
        end


        function num = size(obj, val)
            parent = obj.find(val);
            num = -obj.data(parent);
        end

        function parent = find(obj, parent)
            idx_traversed = zeros(1,200);
            i = 1;
            while obj.data(parent) > 0
                parent = obj.data(parent);
                idx_traversed(i) = parent;
                i = i + 1;
            end
            idx_traversed = idx_traversed(idx_traversed > 0);
            obj.data(idx_traversed(1:end-1)) = parent;
        end

        function connect(obj, u, v)
            if obj.is_connected(u, v)
                return;
            end
            parent_u = obj.find(u);
            parent_v = obj.find(v);

            if obj.size(parent_u) > obj.size(parent_v)
                obj.data(parent_u) = obj.data(parent_u) + obj.data(parent_v);
                obj.data(parent_v) = u;
            else
                obj.data(parent_v) = obj.data(parent_v) + obj.data(parent_u);
                obj.data(parent_u) = v;
            end
        end

        function res = is_connected(obj, u, v)
            parent_u = obj.find(u);
            parent_v = obj.find(v);
            res = (parent_u == parent_v);
        end
    end
end