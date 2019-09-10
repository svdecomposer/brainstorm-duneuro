function fc_ecriture_fichier_msh(node,elem,Vn,fname)

% fc_ecriture_fichier_msh(node,elem,Vn,fname)
% Cette fonction permet de créer le fichier maillage *.msh qui sera lu par
% le soft gmesh, elle prend en entrée la liste des neouds sous la
% forme [num_node xn yn zn] et la liste des element sous la forme [num_elem
% n1 n2 n3 n4 id], le nom du fichier de sortie est 'fname'
% Une fois lancer, la fonction lit le fichier de sortie du code FEM
% de zhuxiang, et permet de lire le potentiel de cuaque noeud.
% Elle ne fonction uniquement avec les donnes de potentiel asociée au meme
% maillage
% cette fonction prend en entré la liste des noeuds de maillage node,
% le potentiel associée a chaque noeud , et la liste des elements du maillage.

% Takfarinas Medani, last update 05/05/2014
%http://www.ensta-paristech.fr/~kielbasi/docs/gmsh.pdf

Nombre_de_noeuds=length(node);
Nombre_des_elements=length(elem);
% % numérotation des noeuds et des elements
% for i=1:Nombre_de_noeuds
%     nbno(i)=i;
% end
% for i=1:Nombre_des_elements
%     nbel(i)=i;
% end
% newnode=[nbno' node];
% elem=[nbel' elem];
newnode=node;
newelem=elem;

nn=newnode(:,1);% numéro du noeud
xn=newnode(:,2);% composante x du noeud
yn=newnode(:,3);% composante y du noeud
zn=newnode(:,4);% composante y du noeud


%a='toto2.msh';

% %ouvre ou crée un fichier
fid = fopen(fname,'wt');

%fprintf(fid,'%s\t\n','Maillage'); % teste
%Partie I du fichier
%fprintf(fid,'\r\n');
%% Informations du format du fichier de maillage
fprintf(fid,'%s\r\n','$MeshFormat');
fprintf(fid,'%s\r\n','2.2 0 8');
fprintf(fid,'%s\r\n','$EndMeshFormat ');

%% bloc des noeuds
fprintf(fid,'%s\r\n','$Nodes ');
%fprintf(fid,'%s\r\n',' Dimension    {3}  ');
%fprintf(fid,'\r\n');
fprintf(fid,'%i \r\n',Nombre_de_noeuds);

%écriture des noeuds ligne par ligne nn xn yn zn
for i=1:Nombre_de_noeuds
    fprintf(fid,'%i  %i  %i  %i \r\n',nn(i),xn(i),yn(i),zn(i));
end
fprintf(fid,'%s\r\n','$EndNodes');

%% bloc des elemnts
%ecriture de la partie II du fichier d'entrée
ne=newelem(:,1); %Numéro de l'element
ne1=newelem(:,2); %premier noeud de l'élément
ne2=newelem(:,3); %2 éme  //     //
ne3=newelem(:,4); %3 éme  //     //
ne4=newelem(:,5); %4 éme  //     //
ne5=newelem(:,6); % domaine ID du materiau

elm_type_segment=1;
elm_type_triangle=2;
elm_type_quadrangle=3;
elm_type_tetra=4;

fprintf(fid,'\r\n');
fprintf(fid,'%s\r\n','$Elements');
fprintf(fid,'%i \r\n',Nombre_des_elements);

for i=1:Nombre_des_elements
   %fprintf(fid,'%i %i %s  %i  %i  %i %i  %i %i \r\n',ne(i),elm_type_tetra,'2',0 ,ne5(i),ne1(i),ne2(i),ne3(i),ne4(i));
    fprintf(fid,'%i %i %s  %i  %i  %i %i  %i %i \r\n',ne(i),elm_type_tetra,'2',ne5(i)-1,0,ne1(i),ne2(i),ne3(i),ne4(i)); % modification of TIM

end
fprintf(fid,'%s\r\n','$EndElements');


%% bloc physical Names
fprintf(fid,'%s\r\n','$PhysicalNames');
nombre_de_couches=4;
fprintf(fid,'%i \r\n',nombre_de_couches);
fprintf(fid,'%i %i %s\r\n','1 1 toto1');
fprintf(fid,'%i %i %s\r\n','2 2 toto2');
fprintf(fid,'%i %i %s\r\n','3 3 toto3');
fprintf(fid,'%i %i %s\r\n','4 4 toto4');
fprintf(fid,'%s\r\n','$EndPhysicalNames');


%% $NodeData
% http://geuz.org/gmsh/doc/texinfo/gmsh.html#SEC62
fprintf(fid,'%s\r\n','$NodeData');
fprintf(fid,'%i \r\n',1); % one string tag:
fprintf(fid,'%s\r\n','"A scalar view"');
fprintf(fid,'%i\r\n',1); %one real tag:
fprintf(fid,'%i\r\n',0.0); %the time value (0.0)
fprintf(fid,'%i\r\n',3); % three integer tags:
fprintf(fid,'%i\r\n',0); %the time step (0; time steps always start at 0)
fprintf(fid,'%i\r\n',1); % 1-component (scalar) field
fprintf(fid,'%i\r\n',Nombre_de_noeuds); % nb associated nodal values

%Vn=fc_nodal_potential();
for i=1:Nombre_de_noeuds
    fprintf(fid,'%i %i \r\n',nn(i),Vn(i)-Vn(1));
end
fprintf(fid,'%s\r\n','$End$NodeData');
fclose(fid);
end


