% auteur Khmarou mohammed nidal, Alexandre Adamski, Antoine Beyet .
% Tester sur des exemples vari�s (utiliser notamment le script test)
%
function [x,F] = simplexe1(OPT,c,A,b)
%
%% Fonction simplexe
%
% Le pb : Opt F(x) = c'*x
%         Ax = b
%         x >= 0
% 
%% EN ENTREE
%  OPT = +1 si pb de maximisation
%  OPT = -1 si pb de minimisation
%  c : vecteur de poids des variables dans le crit�re � maximiser.
%  A : matrice d�crivant les contraintes �galit�.
%  b : vecteur second membre des contraintes egalit�.
%
%% EN SORTIE
%  x : vecteur des valeurs des variables maximisant la valeur du crit�re.
%  F : valeur optimale du critere.
%
%% EN VARIABLES INTERNES
%  JB: le vecteur des indices de la base courante (ou du support).
%  JN: l'ensemble des indices hors-base courants.
%  GAMMA est le tableau simplexe courant
%  GAMMA(:,1:n) contient les d�compositions des vecteurs colonnes de A sur
% la base courante JB
%  GAMMA(:,n+1) contient le sommet courant
%  alpha indice du vecteur colonne de A qui entre dans la base
%  beta indice du vecteur colonne de A qui sort de la base
%  indbeta indice tel que beta = JB(indbeta)
%% REMARQUES
% La m�thode de la base artificielle n'a pas �t� implant�e
% Aucune proc�dure anti-cyclage n'a �t� implant�e
% Il peut y avoir cyclage si l'on rencontre un sommet d�g�n�r�
%
%% DEBUT DU PROGRAMME
m = size(A,1);
n = size(A,2);
J = 1:n;
JN = 1:n-m;
JB = setdiff(J,JN);
%
%% Pr�traitement
% Changer les signes des �quations si b(i) < 0
% On rend ainsi b >=0
s = sign(b);
s(s==0) = 1;
A= repmat(s,1,n).*A; 
b=sign(b).*b ;
%
%% PHASE I
% Trouver un sommet initial
if any(any(A(:,n-m+1:n) == eye(m)))
    % la base canonique A(:,nim+1) ... A(:,n) est une base r�alisable
    % puisque b>=0
    % x=(0,b) est donc un sommet initial
    GAMMA = [A b] ; 
else
    disp('Appliquer la m�thode de la base artificielle')
    return
end
%
%% PHASE II
% Trouver un sommet optimal � partir du sommet initial
%
z = c(JB)'*GAMMA(:,JN) ; 
pentes = c(JN)-z ;  % pentes contient les mesures des pentes des chemins partant du sommet courant
%% Step 1. Test d'optimalit�
while any(OPT*pentes > 0) % Y-a-t-il un chemin am�liorant ?
    %
    %% Step 2. Test d'existence de solution optimale
    indJNP = find(OPT*pentes>0); %indJNP : indices dans le vecteur des pentes des chemins am�liorant
    JNP = JN(indJNP);    %JNP : indices j des vecteurs Aj d�finissant des chemins am�liorant (xj > 0)
    % Existe-t-il un vecteur Aj, j dans JNP, dont toutes les composantes sur la
    % base courante soient n�gatives ou nulles ?
    %---------------------------------------------------------------------------------------------------------------------------------
    % r�ponse : non il n'existe pas parce que s'il existe alors la demi
    % droite Cj est incluse dans l'ensemble des contraintes C , qui n'est
    % donc pas born� . 
    %---------------------------------------------------------------------------------------------------------------------------------
    % Il d�finit alors un chemin infini (xj > 0) admissible (inclus dans l'ensemble des contraintes)
    % sur lequel le crit�re croit (OPT = 1) ou d�croit (OPT=-1) infiniment
    if not(any(any(A>0))) || any(OPT*A(JNP) <= 0)
        disp('pas de solution optimale')
        x=Inf; 
        F = OPT*Inf;
        return
    end
    %
    %% Step 3. D�termination du vecteur A(:,alpha) entrant dans la base
    % Variante du compromis (choix du chemin am�liorant poss�dant la plus forte pente)
    [~,indalpha] = max(OPT*pentes); %indalpha : indice dans pente du chemin am�liorant de plus forte pente
    alpha = JN(indalpha); %alpha : le chemin x(alpha) > 0 va �tre suivi par le randonneur
    %
    %% Step 4. D�termination du vecteur A(:,beta) sortant de la base
    VEC = abs(double(GAMMA(:,alpha)>0) .* GAMMA(:,alpha));
    % VEC(i) = GAMMA(i,alpha) si GAMMA(i,alpha) > 0
    % VEC(i) = +0             si GAMMA(i,alpha) <= 0
    % Se rappeler aussi que 1/+0 = Inf !!
    [~,indbeta] = min(GAMMA(:,n+1)./VEC);
    % donc beta = JB(indbeta);
    %
    %% Step 5. Changement de base et calcul du nouveau tableau simplexe
    %
    % Changement de base
    JB(indbeta) = alpha; 
    JN = setdiff(J,JB);
    %
    % Calcul du nouveau tableau simplexe GAMMA
    % Regle de pivotage du SIMPLEXE
    % GAMMA(indbeta,alpha) est le pivot de l'iteration
    %
    GAMMA(indbeta,:) = GAMMA(indbeta,:)/GAMMA(indbeta,alpha);
    GAMMA_inter =[GAMMA(1:indbeta-1,:) ; 
    GAMMA(indbeta+1:m,:)];
    GAMMA_inter = GAMMA_inter - GAMMA_inter(:,alpha)*GAMMA(indbeta,:);
    GAMMA = [GAMMA_inter(1:indbeta-1,:); 
    GAMMA(indbeta,:) ; 
    GAMMA_inter(indbeta:(m-1),:)];
    %
    z = c(JB)'*GAMMA(:,JN);
    pentes = c(JN)'-z;
end
%
% Il n'y a plus de chemin am�liorant: on a trouv� une solution localement
% optimale et donc globalement optimale puisque (P) est convexe
% Solution optimale
x = zeros(n,1);
x(JB) = GAMMA(:,n+1);
% Valeur optimale du critere
F = c'*x;
