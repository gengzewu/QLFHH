%NSGA-II
function Population = FLLnsgaii(Problem,Population,Rate,Acc)
clc;
format compact;%�ո����
tic;%��¼����ʱ�� 
% if Problem == 'DTLZ3'
%     Generations = 10;
% elseif Problem == 'DTLZ4'
%     Generations = 10;
% else 
    Generations = 2;
% end
    
    % ���з�֧������
    [~,FrontNo,CrowdDis] = NSGAIIEnvironmentalSelection(Population,Problem.N);
    
    %��ʼ����
    for Gene = 1 : Generations    
        %�����Ӵ���
        MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis); 
        OffDec     = OperatorGA(Problem,Population(MatingPool).decs);
        %% FDV
        if Problem.FE/Problem.maxFE <= Rate
            Offspring = FDVoperator(Problem,Rate,Acc,OffDec);
        else
%             Offspring  = OperatorGA(Problem,Population(MatingPool));
            Offspring = Problem.Evaluation(OffDec);
        end
%         MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis); %�����ѡ��2�Ľ�����ѡ��ʽ
%         Offspring  = OperatorGA(Problem,Population(MatingPool)); %����,���죬Խ�紦�������µ���Ⱥ
        [Population,FrontNo,CrowdDis] = NSGAIIEnvironmentalSelection([Population,Offspring],Problem.N);
    
    end
end    


function [Population,FrontNo,CrowdDis] = NSGAIIEnvironmentalSelection(Population,N)
% The environmental selection of NSGA-II

    %% Non-dominated sorting
    [FrontNo,MaxFNo] = NDSort(Population.objs,Population.cons,N);
    Next = FrontNo < MaxFNo;
    
    %% Calculate the crowding distance of each solution
    CrowdDis = CrowdingDistance(Population.objs,FrontNo);
    
    %% Select the solutions in the last front based on their crowding distances
    Last     = find(FrontNo==MaxFNo);
    [~,Rank] = sort(CrowdDis(Last),'descend');
    Next(Last(Rank(1:N-sum(Next)))) = true;
    
    %% Population for next generation
    Population = Population(Next);
    FrontNo    = FrontNo(Next);
    CrowdDis   = CrowdDis(Next);
end