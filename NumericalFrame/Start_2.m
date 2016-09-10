% variables based on different problems
num_cell = 100;
num_var = 2;
num_eqn = num_var;
num_dim = 1;
num_s = 1;
dt = 1;
var_n = [5000;0.8];% p_o and S_o
t = 1000;
num_J = 3;
num_S = 1;
num_O = 1;

% Create Structure fields
% J_info
j_f1 = 'dir_index';
j_val1 = {cell(num_dim,1)};
j_f2 = 'J_eqn';
j_val2 = {cell(num_eqn,1)};
j_f3 = 'dJdv_i';
j_val3 = {cell(num_eqn,num_var)};
j_f4 = 'dJdv_adj';
j_val4 = {cell(num_eqn,num_var)};
J_info = struct(j_f1,j_val1,j_f2,j_val2,j_f3,j_val3,j_f4,j_val4);

% S_info
s_f1 = 'index';
s_val1 = {cell(1,1)};
s_f2 = 'S_eqn';
s_val2 = {cell(num_eqn,1)};
s_f3 = 'dSdv_i';
s_val3 = {cell(num_eqn,num_var)};
S_info = struct(s_f1,s_val1,s_f2,s_val2,s_f3,s_val3);
% N_info: old term;
o_f1 = 'index';
o_val1 = {cell(1,1)};
o_f2 = 'O_eqn';
o_val2 = {cell(num_eqn,1)};
O_info = struct(o_f1,o_val1,o_f2,o_val2);
% Here the O_info = S_info on the last time step

J_info(1). dir_index{1}=2:100;
J_info(1). dir_index{2}=1:99;
J_info(2). dir_index{1}=1;
J_info(2). dir_index{2}=[];
J_info(3). dir_index{1}=[];
J_info(3). dir_index{2}=100;
J_info(1). J_eqn{1}=@(cell_index,var_array,dim,adj_index,adj_table)(((logical((var_array(1,cell_index)>var_array(1,adj_index(cell_index,dim,adj_table)))).*(var_array(2,cell_index).^2)+(1-logical((var_array(1,cell_index)>var_array(1,adj_index(cell_index,dim,adj_table))))).*(var_array(2,adj_index(cell_index,dim,adj_table)).^2)).*0.01).*(var_array(1,adj_index(cell_index,dim,adj_table))-var_array(1,cell_index)));
J_info(1). J_eqn{2}=@(cell_index,var_array,dim,adj_index,adj_table)(((logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table))))))).*(1-(var_array(2,cell_index).^0.5))+(1-logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table)))))))).*(1-(var_array(2,adj_index(cell_index,dim,adj_table)).^0.5))).*0.01).*((var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table)))))-(var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))));
J_info(2). J_eqn{1}=@(cell_index,var_array,dim,adj_index,adj_table)0;
J_info(2). J_eqn{2}=@(cell_index,var_array,dim,adj_index,adj_table)(1000-(var_array(1,cell_index)-(5.*(1-var_array(2,cell_index)))));
J_info(3). J_eqn{1}=@(cell_index,var_array,dim,adj_index,adj_table)(((var_array(2,cell_index).^2).*0.01).*var_array(1,cell_index));
J_info(3). J_eqn{2}=@(cell_index,var_array,dim,adj_index,adj_table)(((1-(var_array(2,cell_index).^0.5)).*0.01).*(var_array(1,cell_index)-(5.*(1-var_array(2,cell_index)))));
J_info(1). dJdv_i{1,1}=@(cell_index,var_array,dim,adj_index,adj_table)(((logical((var_array(1,cell_index)>var_array(1,adj_index(cell_index,dim,adj_table)))).*(var_array(2,cell_index).^2)+(1-logical((var_array(1,cell_index)>var_array(1,adj_index(cell_index,dim,adj_table))))).*(var_array(2,adj_index(cell_index,dim,adj_table)).^2)).*0.01).*-1);
J_info(1). dJdv_i{2,1}=@(cell_index,var_array,dim,adj_index,adj_table)(((logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table))))))).*(1-(var_array(2,cell_index).^0.5))+(1-logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table)))))))).*(1-(var_array(2,adj_index(cell_index,dim,adj_table)).^0.5))).*0.01).*-1);
J_info(1). dJdv_i{1,2}=@(cell_index,var_array,dim,adj_index,adj_table)((var_array(1,adj_index(cell_index,dim,adj_table))-var_array(1,cell_index)).*(0.01.*(logical((var_array(1,cell_index)>var_array(1,adj_index(cell_index,dim,adj_table)))).*(2.*var_array(2,cell_index))+(1-logical((var_array(1,cell_index)>var_array(1,adj_index(cell_index,dim,adj_table))))).*0)));
J_info(1). dJdv_i{2,2}=@(cell_index,var_array,dim,adj_index,adj_table)((((var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table)))))-(var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))).*(0.01.*(logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table))))))).*(0-(0.5.*(var_array(2,cell_index).^-0.5)))+(1-logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table)))))))).*0)))+(((logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table))))))).*(1-(var_array(2,cell_index).^0.5))+(1-logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table)))))))).*(1-(var_array(2,adj_index(cell_index,dim,adj_table)).^0.5))).*0.01).*-5));
J_info(2). dJdv_i{1,1}=@(cell_index,var_array,dim,adj_index,adj_table)0;
J_info(2). dJdv_i{2,1}=@(cell_index,var_array,dim,adj_index,adj_table)-1;
J_info(2). dJdv_i{1,2}=@(cell_index,var_array,dim,adj_index,adj_table)0;
J_info(2). dJdv_i{2,2}=@(cell_index,var_array,dim,adj_index,adj_table)-5;
J_info(3). dJdv_i{1,1}=@(cell_index,var_array,dim,adj_index,adj_table)((var_array(2,cell_index).^2).*0.01);
J_info(3). dJdv_i{2,1}=@(cell_index,var_array,dim,adj_index,adj_table)((1-(var_array(2,cell_index).^0.5)).*0.01);
J_info(3). dJdv_i{1,2}=@(cell_index,var_array,dim,adj_index,adj_table)(var_array(1,cell_index).*(0.01.*(2.*var_array(2,cell_index))));
J_info(3). dJdv_i{2,2}=@(cell_index,var_array,dim,adj_index,adj_table)(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index)))).*(0.01.*(0-(0.5.*(var_array(2,cell_index).^-0.5)))))+(((1-(var_array(2,cell_index).^0.5)).*0.01).*5));
J_info(1). dJdv_adj{1,1}=@(cell_index,var_array,dim,adj_index,adj_table)((logical((var_array(1,cell_index)>var_array(1,adj_index(cell_index,dim,adj_table)))).*(var_array(2,cell_index).^2)+(1-logical((var_array(1,cell_index)>var_array(1,adj_index(cell_index,dim,adj_table))))).*(var_array(2,adj_index(cell_index,dim,adj_table)).^2)).*0.01);
J_info(1). dJdv_adj{2,1}=@(cell_index,var_array,dim,adj_index,adj_table)((logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table))))))).*(1-(var_array(2,cell_index).^0.5))+(1-logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table)))))))).*(1-(var_array(2,adj_index(cell_index,dim,adj_table)).^0.5))).*0.01);
J_info(1). dJdv_adj{1,2}=@(cell_index,var_array,dim,adj_index,adj_table)((var_array(1,adj_index(cell_index,dim,adj_table))-var_array(1,cell_index)).*(0.01.*(logical((var_array(1,cell_index)>var_array(1,adj_index(cell_index,dim,adj_table)))).*0+(1-logical((var_array(1,cell_index)>var_array(1,adj_index(cell_index,dim,adj_table))))).*(2.*var_array(2,adj_index(cell_index,dim,adj_table))))));
J_info(1). dJdv_adj{2,2}=@(cell_index,var_array,dim,adj_index,adj_table)((((var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table)))))-(var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))).*(0.01.*(logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table))))))).*0+(1-logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table)))))))).*(0-(0.5.*(var_array(2,adj_index(cell_index,dim,adj_table)).^-0.5))))))+(((logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table))))))).*(1-(var_array(2,cell_index).^0.5))+(1-logical(((var_array(1,cell_index)-(5.*(1-var_array(2,cell_index))))>(var_array(1,adj_index(cell_index,dim,adj_table))-(5.*(1-var_array(2,adj_index(cell_index,dim,adj_table)))))))).*(1-(var_array(2,adj_index(cell_index,dim,adj_table)).^0.5))).*0.01).*5));
J_info(2). dJdv_adj{1,1}=@(cell_index,var_array,dim,adj_index,adj_table)0;
J_info(2). dJdv_adj{2,1}=@(cell_index,var_array,dim,adj_index,adj_table)0;
J_info(2). dJdv_adj{1,2}=@(cell_index,var_array,dim,adj_index,adj_table)0;
J_info(2). dJdv_adj{2,2}=@(cell_index,var_array,dim,adj_index,adj_table)0;
J_info(3). dJdv_adj{1,1}=@(cell_index,var_array,dim,adj_index,adj_table)0;
J_info(3). dJdv_adj{2,1}=@(cell_index,var_array,dim,adj_index,adj_table)0;
J_info(3). dJdv_adj{1,2}=@(cell_index,var_array,dim,adj_index,adj_table)0;
J_info(3). dJdv_adj{2,2}=@(cell_index,var_array,dim,adj_index,adj_table)0;
S_info(1). index{1}=1:100;
S_info(1). S_eqn{1}=@(cell_index,var_array,dim,adj_index,adj_table)(var_array(2,cell_index).*0.35);
S_info(1). S_eqn{2}=@(cell_index,var_array,dim,adj_index,adj_table)((1-var_array(2,cell_index)).*0.35);
S_info(1). dSdv_i{1,1}=@(cell_index,var_array,dim,adj_index,adj_table)0;
S_info(1). dSdv_i{2,1}=@(cell_index,var_array,dim,adj_index,adj_table)0;
S_info(1). dSdv_i{1,2}=@(cell_index,var_array,dim,adj_index,adj_table)0.35;
S_info(1). dSdv_i{2,2}=@(cell_index,var_array,dim,adj_index,adj_table)-0.35;
O_info(1). index{1}=1:100;
O_info(1). O_eqn{1}=@(cell_index,var_array,dim,adj_index,adj_table)(var_array(2,cell_index).*0.35);
O_info(1). O_eqn{2}=@(cell_index,var_array,dim,adj_index,adj_table)((1-var_array(2,cell_index)).*0.35);


Solution = NRsolver_2(num_var, num_cell, num_dim,J_info, S_info, O_info,var_n,dt,t);
