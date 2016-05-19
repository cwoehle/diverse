


cd '/Users/christian/Projekt/Phaeodactylum/corrected'
fileID = fopen('prok_nn.txt','w');
files = dir('*_tree.txt');
%files = dir('*.rooted');


x=0;
y=0;
z=0;

%%%Giddys randomization
%ref=find(t.split(75,:))
%notref=setdiff(1:t.notu,ref)
%rndnoref=notref(randperm(numel(notref)))
%nn=1:8
%t.ids(nn)
%t.ids(rndnoref(nn))




for f=files';

    z=z+1;
file=f.name;
%file='ssPt00002_e.phy_phyml_tree.txt';
%file='ssPt01628.phy_phyml_tree.txt';
%file='ssPt02689_e.phy_phyml_tree.txt'
%file='ssPt00002_e.phy_phyml_tree.txt'
%file='ssPt01427_e.phy_phyml_tree.txt'
%file='test.tree'
%file
tree1 =  fileread(file);
%tree1
tree= newick(tree1);
t=tree;
%tcat 

%bacteria in split
bacteria=strncmp(t.ids,'b',1);
%archaea in split
archaea=strncmp(t.ids,'a',1);
%eukaryota in split
eukaryota=~(bacteria+archaea);
%phaeodactylum
phaeodactylum=strncmp(t.ids,'ssPt',4);
ph=phaeodactylum;

%get only splits wiht Phaeodactylum (is always one)
t.split(find(sum(~t.split(:,ph),2)),:)=~t.split(find(sum(~t.split(:,ph),2)),:);



%splits=size(t.split)
%sp=[]
%for i=1:splits(1)
%
%    if sum(t.split(i,ph),2)==1
%        sp(i,:)=t.split(i,:);
%    else
%        sp(i,:)=~t.split(i,:);
%    end
%end
  


%counts per split
n1=sum(t.split,2);
n0=sum(~t.split,2);
nb=sum(bacteria);
na=sum(archaea);
ne=sum(eukaryota);

%only if prokaryotes avilable
if na>0 || nb>0
%file
%tree1
%tree
    
    x=x+1;
%counts both split sides
%nb1=sum(t.split(:,bacteria),2)
%nb0=sum(~t.split(:,bacteria),2)
%na1=sum(t.split(:,archaea),2)
%na0=sum(~t.split(:,archaea),2)
ne1=sum(t.split(:,eukaryota),2);
%ne0=sum(~t.split(:,eukaryota),2)

%monopholetic eukaryotic splits with ph
positive=n1==ne1;
valid=t.split(positive,:);
%find nearest neighbors in unrooted trees

%biggest split including ph and monophyletic eukaryotes
[m,best]=max(sum(valid,2));
t.ids(valid(best,:));

%%%%%%%%%%%WHAT if only one possinbility would be the whole tree? (Only one
%%%%%%%%%%%additiuonal species? in the tree)

%get smallest split that inlcudesthe best split (best), but more species
subst=t.split-repmat(valid(best,:),[size(t.split,1),1]);
minus=min(subst');
plus=max(subst');
minus(minus==0)=1;
minus(minus==-1)=0;
minus(plus==0)=0;

%extract split
cand=t.split(logical(minus),:);

if sum(sum(cand))>0

sum(valid(best,:));
count=sum(cand');

%cand(count==min(count),:)

%%%%%%%%%%%WHAT if only one possinbility? Meaning one species left

%now we have two possible cases
better=cand(count==min(count),:);

poss1=t.ids(logical(better(1,:)-valid(best,:)));
poss2=t.ids(logical(~better(1,:)));

%bacteria in split
bac1=strncmp(poss1,'b',1);
%archaea in split
arc1=strncmp(poss1,'a',1);
%eukaryota in split
euk1=~(bac1+arc1);

%bacteria in split
bac2=strncmp(poss2,'b',1);
%archaea in split
arc2=strncmp(poss2,'a',1);
%eukaryota in split
euk2=~(bac2+arc2);

poss3=[poss1,poss2];
%bacteria in split
bac3=strncmp(poss3,'b',1);
%archaea in split
arc3=strncmp(poss3,'a',1);
%eukaryota in split
euk3=~(bac3+arc3);


P1=[sum(bac1) sum(arc1) sum(euk1)];
P2=[sum(bac2) sum(arc2) sum(euk2)];
P3=[sum(bac3) sum(arc3) sum(euk3)];

if (P1(2)>0 && P1(1)>0) && (P2(2)==0 || P2(1)==0)
    %winner is 2
      if P2(2)>0
      poss2=[poss2(bac2) {'aa'}];
    else
      poss2=poss2(bac2);
    end
    temp=char(poss2);
    part2=temp(:,1:2);
    uni2=unique(cellstr(part2));
    
    string=sprintf('%s,',uni2{:});
    fprintf(fileID,'%s\t%s\t%s\n',file,string,'Hit');
    
    
elseif (P2(2)>0 && P2(1)>0) && (P1(2)==0 || P1(1)==0)
    %winner is 1
       %temp=char(poss1(bac1));
    if P1(2)>0
      poss1=[poss1(bac1) {'aa'}];
    else
      poss1=poss1(bac1);
    end
    temp=char(poss1);
    part1=temp(:,1:2);
    uni1=unique(cellstr(part1));
    
    string=sprintf('%s,',uni1{:});
    fprintf(fileID,'%s\t%s\t%s\n',file,string,'Hit');
    
else
    %No winner
        if P3(2)>0
      poss3=[poss3(bac3) {'aa'}];
    else
      poss3=poss3(bac3);
    end
    temp=char(poss3);
    part3=temp(:,1:2);
    uni3=unique(cellstr(part3));
    
    string=sprintf('%s,',uni3{:});
    fprintf(fileID,'%s\t%s\t%s\n',file,string,'Unresolved');
    
    
end;


%compare monophyly of both cases
%groups archaea, eukaryota and different groups of bacteria
%Was wäre wenn wir EUkaryota ignorieren => Mögliche Fälle leicht
%verschobene Phylogenetische Position oder Paralogie. In beiden Fällen
%sollte, wenn genug Prokaryoten vorhanden das keine Rolle spielen
%Archae als eine Gruppe und Bacteria in Sub-Gruppen, da inletzteren schon
%mehr bekannt ist über die Ursprünge species sampling größer erscheint

%check bacteria subcategories


%temp=char(poss1(bac1));
%if P1(2)>0
%    poss1=[poss1(bac1) {'aa'}];
%%else
 %   poss1=poss1(bac1);
%end
%temp=char(poss1);
%part1=temp(:,1:2);

%if P2(2)>0
%    poss2=[poss2(bac2) {'aa'}];
%else
%%    poss2=poss2(bac2);
%end
%temp=char(poss2);
%part2=temp(:,1:2);

%uni1=unique(cellstr(part1));
%%uni2=unique(cellstr(part2));
%unim=unique([uni1; uni2]);


%if size(uni1,1)==1 && size(uni2,1)>1
%    'Nearest neighbor'
%%    uni1'
%elseif size(uni1,1)>1 && size(uni2,1)==1
%    'Nearest neighbor'
%%    uni2'
%elseif size(unim,1)==1
%%    'Nearest neighbor merge'
%    unim'
    
%else


%    if size(uni1,1) > size(uni2,1)
       % 'No unique nearest neighbor'
      %  uni2'
%        string=sprintf('%s,',uni2{:});
%        fprintf(fileID,'%s\t%s\t%s\n',file,string,'Hit');
%    elseif size(uni2,1) > size(uni1,1)
%      %  'No unique nearest neighbor'
%      string=sprintf('%s,',uni1{:});
%      fprintf(fileID,'%s\t%s\t%s\n',file,string,'Hit');
       % uni1'
%    else
       % 'No unique nearest neighbor merge'
 %      string=sprintf('%s,',unim{:});
  %     fprintf(fileID,'%s\t%s\t%s\n',file,string,'Unresolved');
       % unim'
   % end
        
%end

%monophyly by score 4 times more eukaryotes and prokaryotes
%score=(ne1-((n1-ne1)*1))
%[m,best]=max(score)

%score(score==m)
%splits=t.split(find(score==m),:)
   
   %in several equal values choos the one seperating most otus
%[m2 index] = max((sum(splits').*sum(~splits'))')

%Check number ofeukaryotes
%bac2=strncmp(t.ids(splits(index,:)),'b',1)
%arch2=strncmp(t.ids(splits(index,:)),'a',1)
%prok1=~(bac2+arch2)
%
%new=subtree(t,t.ids(valid(best,:)))

%only if the subtree makes sense
%if m > 3
  %if sum(prok1) > 3  
%t=tree2root(t,valid(best,:))
%nt=newick(t,'R')
%get eukaryotic subtree
%new=subtree(t,t.ids(splits(index,:)))
%%remove remining prokaryotes if there are any
%bac3=strncmp(new.ids,'b',1)
%arch3=strncmp(new.ids,'a',1)
%prok2=(bac3+arch3)

%ind=getbyname(new,new.ids(logical(prok2)));
%tr = prune(new,ind);



%nt=newick(new,'R');

%fileID = fopen(strcat(file,'.prok.rooted'),'w');
%fprintf(fileID,'%s\n',nt);
%fclose(fileID);
%strcat(file,'.prok.rooted');

%end
else
    poss1=t.ids(~valid(best,:));
    
    
    
    %bacteria in split
    bac1=strncmp(poss1,'b',1);
    %archaea in split
    arc1=strncmp(poss1,'a',1);
    %eukaryota in split
    euk1=~(bac1+arc1);
    
    P1=[sum(bac1) sum(arc1) sum(euk1)];
    
    if P1(2)>0
    poss1=[poss1(bac1) {'aa'}];
    else
    poss1=poss1(bac1);
    end
    
    temp=char(poss1);
    part1=temp(:,1:2);
    fprintf(fileID,'%s\t%s,\t%s\n',file,part1,'Singleton');

end

else
    
   fprintf(fileID,'%s\t-\t%s\n',file,'Eukaryotic');
    
   
end
end

fclose(fileID);

x
y
z
