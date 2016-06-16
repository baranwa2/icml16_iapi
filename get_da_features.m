function phi_da = get_da_features(s_da_td,params)
run('get_global_constants.m')
%features are:
%[max_t(eff_demand);min_t(eff_demand);tot_max_gen(ai);tot_min_gen(ai);tot_cost(ai)]
num_actions = size(params.action_set,2);
effectiveDemand = sum(s_da_td.demand-s_da_td.wind,1);
maxD = max(effectiveDemand);
minD = min(effectiveDemand);
avgD = mean(effectiveDemand);
max_g_mat = repmat(params.mpcase.gen(:,PMAX),[1,num_actions]);
max_g = sum(params.action_set.*max_g_mat,1);

min_g_mat = repmat(params.mpcase.gen(:,PMIN),[1,num_actions]);
min_g = sum(params.action_set.*min_g_mat,1);
cost_mat = repmat(params.ci,[1,num_actions]);
cost = sum(params.action_set.*cost_mat,1);

U_violation = -((max_g - maxD)<0);
% U_D = max_g - avgD;
% D_L = avgD - min_g;
L_violation = -((minD - min_g)<0);

maxD_vec = repmat(maxD,[1,size(params.action_set,2)]);
minD_vec = repmat(minD,[1,size(params.action_set,2)]);
avgD_vec = repmat(avgD,[1,size(params.action_set,2)]);


penalty = @(x) -(2./(max_g-min_g).*(x-min_g)-1).^2;
% penalty_max = penalty(maxD_vec);
% penalty_min = penalty(minD_vec);
penalty_avg = penalty(avgD_vec);

norm_factor = (max(max_g) - min(min_g))/2;

action_features = eye(size(params.action_set,2));

% phi_da = [ones(size(U_MD));...
%           [U_MD;U_D;D_L;mD_L]./norm_factor;...
%            action_features];
phi_da = [ones(size(U_violation));U_violation;L_violation;...
          penalty_avg;action_features];
%% normalize phi's columns to not give advantage to some actions over others
%sum
% phi_da=phi_da./repmat(sum(phi_da,1),[size(phi_da,1),1]);

%l2 norm
% phi_da_norm = arrayfun(@(c)(norm(phi_da(:,c))), 1:size(phi_da,2));
% phi_da=phi_da./repmat(phi_da_norm,[size(phi_da,1),1]);

