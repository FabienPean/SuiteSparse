function graph_demo (n)
%GRAPH_DEMO: graph partitioning demo
%   graph_demo(n) constructs an set of n-by-n 2D grids, partitions them, and
%   plots them in one-second intervals.  n is optional; it defaults to 60.
%
%   See also DELSQ, NUMGRID, GPLOT, TREEPLOT

%   Copyright 2006, Timothy A. Davis
%   http://www.cise.ufl.edu/research/sparse

if (nargin < 1)
    % construct a 60-by-60 grid
    n = 60 ;
end

for region = {'Square', 'C' 'Disc', 'Annulus', 'Heart', 'Butterfly', 'L'}

    % construct the grid
    region = region {1} ;
    g = numgrid (region (1), n) ;
    x = repmat (0:n-1, n, 1) ;
    y = repmat (((n-1):-1:0)', 1, n)  ;
    A = delsq (g) ;
    x = x (find (g)) ;
    y = y (find (g)) ;

    % plot the original grid
    clf
    subplot (2,2,1)
    gplot (A, [x y]) ;
    title (sprintf ('%s-shaped 2D grid', region)) ;
    axis equal
    axis off

    % bisect the graph
    s = bisect (A) ;
    [i j] = find (A) ;
    subplot (2,2,2)
    gplot (sparse (i, j, s(i) == s(j)), [x y]) ;
    title ('node bisection') ;
    axis equal
    axis off

    % nested dissection
    nsmall = floor (size (A,1) / 2) ;
    defaults = 0 ;
    while (1)
        if (defaults)
            % use defaults
            [p cp cmember] = nesdis (A) ;
        else
            [p cp cmember] = nesdis (A, 'sym', nsmall) ;
        end

        % plot the components
        subplot (2,2,3)
        gplot (sparse (i, j, cmember(i) == cmember (j)), [x y]) ;
        if (defaults)
            title ('nested dissection (defaults)') ;
        else
            title (sprintf ('nested dissection, nsmall %d', nsmall)) ;
        end
        axis equal
        axis off

        % plot the separator tree
        subplot (2,2,4)
        treeplot (cp, 'ko')
        title ('separator tree') ;
        axis equal
        axis off

        drawnow
        pause (1)

        if (defaults)
            break ;
        end

        nsmall = floor (nsmall / 2) ;
        if (nsmall < 20)
            defaults = 1 ;
            pause (2)
        end
    end
end