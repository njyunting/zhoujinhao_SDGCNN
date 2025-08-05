% �ļ������Ʊ���
folder_name1 = '����'; % �ļ�����

% ��ȡ��������
point_cloud = load(sprintf('D:/yunting/data/bigpicture/%s.txt', folder_name1));

% ��ȡ�������������ǩ
point_cloud_X = point_cloud(:, 1);
point_cloud_Y = point_cloud(:, 2);
point_cloud_Z = point_cloud(:, 3);
labels = point_cloud(:, 8); % �ڰ���Ϊ����ǩ

% ��ȡ����ͱ���Ϣ
centroids_data = readtable(sprintf('D:/yunting/data/new/quanzhi/%s_centroids.csv', folder_name1));
edges_data = readtable(sprintf('D:/yunting/data/new/quanzhi/%s_edges_weights.csv', folder_name1));

% ��ȡ��������
X_centroids = centroids_data.X;
Y_centroids = centroids_data.Y;
Z_centroids = centroids_data.Z;

% ��ȡ����Ϣ
Node1 = edges_data.Node1 + 1; % MATLAB ������1��ʼ
Node2 = edges_data.Node2 + 1;
Weights = edges_data.Weight;

% ��������ǩ����Ӧ��ɫ��͸����
label_colors = [
    0, 0.78, 0.63, 0.78, 0.7;  % ����ɫ
    1, 0.5, 0.5, 0.5, 0.8;            % ��ɫ
    2, 0, 0, 1, 0.4;    % ӫ��ǳ��ɫ
    3, 0, 1, 0, 0.4;            % ��ɫ
    4, 1, 1, 0, 0.5;            % ��ɫ
    5, 0.6, 0.3, 0.1, 0.4;      % ӫ��ǳ��ɫ
    6, 1, 0.75, 0.8, 0.5;       % ��ɫ
    7, 1, 0.5, 0, 0.6;          % ��ɫ
    8, 1, 0, 0, 0.3;            % ��ɫ
];

% ���ò�ͬ����ϡ���
sparsity_map = containers.Map(0:8, [1, 0.5, 1, 1, 1, 1, 1, 1, 0.5]);

% ��ȡ�Զ�����ɫ��ͼƬ
colorbar_image = imread('D:/code/matlab/7329916f45a2323b2fb47085ea2e1540.png');
custom_cmap = squeeze(mean(colorbar_image, 1)) / 255; % ��һ���� [0, 1]

% ����ͼ�δ���
figure;
hold on;

% ����ǩ���ദ�����
for i = 1:size(label_colors, 1)
    current_label = label_colors(i, 1);
    color = label_colors(i, 2:4);
    alpha_value = label_colors(i, 5);
    
    % ��ȡ��ǰ��ǩ�ĵ���
    label_indices = (labels == current_label);
    current_points_X = point_cloud_X(label_indices);
    current_points_Y = point_cloud_Y(label_indices);
    current_points_Z = point_cloud_Z(label_indices);
    
    % ����ϡ���
    sparsity = sparsity_map(current_label);
    num_points = sum(label_indices);
    sample_indices = randperm(num_points, round(sparsity * num_points));
    current_points_X = current_points_X(sample_indices);
    current_points_Y = current_points_Y(sample_indices);
    current_points_Z = current_points_Z(sample_indices);
    
    % ���Ƶ���
    scatter3(current_points_X, current_points_Y, current_points_Z, 1, color, 'filled', 'MarkerFaceAlpha', alpha_value);
end

% ���ƶ���
scatter3(X_centroids, Y_centroids, Z_centroids, 2, 'r', 'filled');

% ���Ʊ�
min_weight = min(Weights);
max_weight = max(Weights);
for k = 1:length(Node1)
    x = [X_centroids(Node1(k)), X_centroids(Node2(k))];
    y = [Y_centroids(Node1(k)), Y_centroids(Node2(k))];
    z = [Z_centroids(Node1(k)), Z_centroids(Node2(k))];
    
    normalized_weight = (Weights(k) - min_weight) / (max_weight - min_weight);
    color_index = round(normalized_weight * (size(custom_cmap, 1) - 1)) + 1;
    color = custom_cmap(color_index, :);
    
    plot3(x, y, z, 'Color', color, 'LineWidth', 0.9);
end

% �������ǩ�ͱ���
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Point Cloud and Supervoxel KNN Graph Visualization');

% ���ñ���Ϊ��ɫ
set(gca, 'Color', 'w');

% �ر�����
grid off;

% �����ɫ��
caxis([min_weight max_weight]);
colormap(custom_cmap);
colorbar;

% ����������������
% axis equal;

hold off;
