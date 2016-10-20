% ==================================================================== 
  function [p,C,iter] = BellmanFord(A,r)


%% Initialisation
% On transforme la matrice A en une liste d'arcs puis on initialise le
% chemin le plus court source-destination (p pour path) et les vecteurs
% coûts (C)

% On récupère la liste d'arc à partir de A
[tail,head,W] = find(A); 

% On récupère le nombre de colonnes de A correspondant au nombre
% d'itérations maximal dans l'algorithme
[~,n] = size(A);

% On récupère le nombre de nonzero value de A pour la boucle for sur les
% arcs
m = nnz(A);

% Shortest path tree of parent pointers
p(1:n,1) = 0;

% Sh. path distances from node i=1:n to the root of the sp tree
C(1:n,1) = Inf;          



%% Algorithme de BellmanFord

% Mise en place des bases du graphe (p,C)
p(r)=0; C(r)=0;

% L'algorithme converge en moins de n-1 iterations si on n'a pas de cycles
% négatifs dans le test d'optimalité
optimal = false;
iter = 1;
while ~optimal && iter < n
    for arc = 1:m
        u = tail(arc);
        v = head(arc);
        duv = W(arc);
        % test d'optimalité
        if C(v) > C(u) + duv
           C(v) = C(u) + duv;
           p(v) = u;
        else
            optimal = true;
        end
    end
    if optimal
        return
    end
    iter = iter + 1;
end
