% �趨�ļ������Ʊ���
folder_name = 'L002_class3';

% ��ȡ����ͱߵ���Ϣ
centroids_data = readtable(sprintf('D:/yunting/data/new/quanzhi/%s_centroids.csv', folder_name));
edges_data = readtable(sprintf('D:/yunting/data/new/quanzhi/%s_edges_weights.csv', folder_name));

% ��ȡ��������
X = centroids_data.X;
Y = centroids_data.Y;
Z = centroids_data.Z;

% ��ȡ�ߵ���Ϣ
Node1 = edges_data.Node1 + 1; % MATLAB ������1��ʼ
Node2 = edges_data.Node2 + 1;
Weights = edges_data.Weight;

% ��ȡ��������
point_cloud = load(sprintf('D:/yunting/data/bigpicture/%s.txt', folder_name));
point_cloud_X = point_cloud(:, 1);
point_cloud_Y = point_cloud(:, 2);
point_cloud_Z = point_cloud(:, 3);

% �����ϡ�������ݣ�����30%
num_points = size(point_cloud, 1);
sample_indices = randperm(num_points, round(0.3 * num_points)); % ���ѡ��30%�ĵ�
point_cloud_X = point_cloud_X(sample_indices);
point_cloud_Y = point_cloud_Y(sample_indices);
point_cloud_Z = point_cloud_Z(sample_indices);

% ��ȡ�Զ�����ɫ��ͼƬ
colorbar_image = imread('D:/code/matlab/7329916f45a2323b2fb47085ea2e1540.png'); % ����ͼƬ��ʽΪ PNG

% ����ɫ��ͼƬת��Ϊ colormap
% ����ͼƬ��ˮƽ����ɫ��
custom_cmap = squeeze(mean(colorbar_image, 1)) / 255; % ��һ���� [0, 1]

% ���Ƶ�������
figure;
scatter3(point_cloud_X, point_cloud_Y, point_cloud_Z, 2, [0.8, 0.8, 0.8], 'filled', 'MarkerFaceAlpha', 0.3); % ǳ��ɫ��20%͸����
hold on;

% ���ƶ���
scatter3(X, Y, Z, 2, 'r', 'filled');

% ��ȡȨֵ����Сֵ�����ֵ
min_weight = min(Weights);
max_weight = max(Weights);

% ���Ʊ�
for k = 1:length(Node1)
    % ��ȡ�ߵ�������������
    x = [X(Node1(k)), X(Node2(k))];
    y = [Y(Node1(k)), Y(Node2(k))];
    z = [Z(Node1(k)), Z(Node2(k))];
    
    % ��һ��Ȩֵ��[0, 1]��Χ
    normalized_weight = (Weights(k) - min_weight) / (max_weight - min_weight);
    
    % ����Ȩֵѡ����ɫ
    color_index = round(normalized_weight * (size(custom_cmap, 1) - 1)) + 1;
    color = custom_cmap(color_index, :);
    
    % ���Ʊ�
    plot3(x, y, z, 'Color', color, 'LineWidth', 0.5);
end

% �������ǩ�ͱ���
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Supervoxel KNN Graph Visualization');

% ���ñ���Ϊ��ɫ
set(gca, 'Color', 'w');

% �ر�����
grid off;

% �����ɫ��
caxis([min_weight max_weight]); % ������ɫ���ķ�Χ
colormap(custom_cmap); % ʹ���Զ�����ɫӳ��
colorbar; % ��ʾ��ɫ��

% ����������������
axis equal; % ȷ������ı�����ͬ

hold off;
