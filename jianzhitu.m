% �ļ������Ʊ���
folder_name1 = 'tree_new5'; % �ļ�����

% ��ȡ��������
point_cloud = load(sprintf('D:/yunting/data/new/%s.txt', folder_name1));

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

% ���õ�����ɫΪ��ɫ
gray_color = [0.83, 0.83, 0.83];

% ����͸����
alpha_value = 1;

% ��ȡ�Զ�����ɫ��ͼƬ
colorbar_image = imread('D:/code/matlab/7329916f45a2323b2fb47085ea2e1540.png');
custom_cmap = squeeze(mean(colorbar_image, 1)) / 255; % ��һ���� [0, 1]

% ����ͼ�δ���
figure;
hold on;

% ���ƻ�ɫ����
scatter3(point_cloud_X, point_cloud_Y, point_cloud_Z, 1, gray_color, 'filled', 'MarkerFaceAlpha', alpha_value);

% ���ƶ���
scatter3(X_centroids, Y_centroids, Z_centroids, 2, 'r', 'filled');

% ���Ʊ�
max_weight = max(Weights);
for k = 1:length(Node1)
    x = [X_centroids(Node1(k)), X_centroids(Node2(k))];
    y = [Y_centroids(Node1(k)), Y_centroids(Node2(k))];
    z = [Z_centroids(Node1(k)), Z_centroids(Node2(k))];
    
    % ��Ȩֵ��һ���� [0, 1]���� max_weight Ϊ��׼����Сֵǿ����Ϊ 0
    normalized_weight = Weights(k) / max_weight;
    color_index = round(normalized_weight * (size(custom_cmap, 1) - 1)) + 1;
    color_index = min(color_index, size(custom_cmap, 1)); % ��ֹԽ��
    color = custom_cmap(color_index, :);
    
    plot3(x, y, z, 'Color', color, 'LineWidth', 1.5);
end

% �������ǩ�ͱ���
xlabel('X');
ylabel('Y');
zlabel('Z');
title('�����볬���� KNN ͼ���ӻ�');

% ���ñ���Ϊ��ɫ
set(gca, 'Color', 'w');

% �ر�����
grid off;

% �����ɫ����ǿ�Ʒ�Χ��0��ʼ
caxis([0 max_weight]);
colormap(custom_cmap);
colorbar;

% ����������������
axis equal;

hold off;
