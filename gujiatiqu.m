% ��ȡ�����ļ�
file_path = 'D:/yunting/data/new/tree_new5.txt';
nearest_neighbors_count = 5;
point_cloud = dlmread(file_path);

% ��ȡ����� supervoxel ��ʶ
coordinates = point_cloud(:, 1:3);
supervoxel_ids = point_cloud(:, 7);

% �ҳ�Ψһ�� supervoxel ��ʶ
unique_supervoxels = unique(point_cloud(:, 7));
num_supervoxels = numel(unique_supervoxels);

% ��ʼ���洢ÿ�� supervoxel ��ĵ�Ԫ����
supervoxel_points_cell = cell(num_supervoxels, 1);

% ��ÿ���㰴�� supervoxel ����洢ǰ������Ϣ
for i = 1:num_supervoxels
    % �ҵ����ڵ�ǰ supervoxel �ĵ������
    indices = find(supervoxel_ids == unique_supervoxels(i));
    
    % ��ȡ���ڵ�ǰ supervoxel �ĵ��ǰ������Ϣ
    supervoxel_points_cell{i} = point_cloud(indices, 1:3);
end

% ��ʼ���洢�������ĵ������
all_centroids = zeros(num_supervoxels, 3);

% �ҳ�ÿ��supervoxel_points_cell{i}�����ĵ㲢���ӻ�
figure;
hold on;

% ���ӻ�ԭʼ���ƣ�����Ϊǳ��ɫ��͸����Ϊ30%
scatter3(coordinates(:, 1), coordinates(:, 2), coordinates(:, 3), 10, [0.8, 0.8, 0.8], 'filled', 'MarkerFaceAlpha', 0.3);

for i = 1:num_supervoxels
    % �ҵ���ǰ supervoxel �ĵ�
    supervoxel_points = supervoxel_points_cell{i};
    
    % ��� supervoxel_points �Ƿ�Ϊ��
    if (numel(supervoxel_points) < 5)
        continue;  % ���Ϊ�գ�������ǰѭ��
    end
    
    % ���㵱ǰ supervoxel �����ĵ�
    centroid = mean(supervoxel_points);
    
    % �����ĵ�洢��������
    all_centroids(i, :) = centroid;
end

% ɾ������Ϊ(0,0,0)�ĵ㣬������ supervoxels �ļ���
zero_indices = find(all(all_centroids == 0, 2));
all_centroids(zero_indices, :) = [];
num_supervoxels = size(all_centroids, 1);

% ����������
distance_matrix = squareform(pdist(all_centroids));

% �洢��������ĵ������Ͷ�Ӧ�ľ���
nearest_neighbors_indices = zeros(num_supervoxels, nearest_neighbors_count);
nearest_neighbors_distances = zeros(num_supervoxels, nearest_neighbors_count);

% �ҵ�ÿ�����ĵ������ھ�
for i = 1:num_supervoxels
    % ��ȡ��ǰ���ĵ㵽�������ĵ�ľ���
    distances_to_other_centroids = distance_matrix(i, :);
    
    % ����ǰ���ĵ��ų����⣬�ҵ������5�����ĵ�
    [sorted_distances, sorted_indices] = sort(distances_to_other_centroids);
    nearest_neighbors_indices(i, :) = sorted_indices(2:nearest_neighbors_count+1); % ��һ�����Լ�
    nearest_neighbors_distances(i, :) = sorted_distances(2:nearest_neighbors_count+1); % ��һ�����Լ�
end

% �������ĵ�
scatter3(all_centroids(:, 1), all_centroids(:, 2), all_centroids(:, 3), 'filled');

% ���Ʊ�
for i = 1:num_supervoxels
    current_centroid = all_centroids(i, :);
    nearest_neighbor_indices = nearest_neighbors_indices(i, :);
    for j = 1:nearest_neighbors_count
        neighbor_index = nearest_neighbor_indices(j);
        neighbor_centroid = all_centroids(neighbor_index, :);
        % ���Ʊ�
        plot3([current_centroid(1), neighbor_centroid(1)], [current_centroid(2), neighbor_centroid(2)], [current_centroid(3), neighbor_centroid(3)], 'b', 'LineWidth', 2);
    end
end

% ����ͼ�α�������ǩ
title('Supervoxel Centroids with Edges to Nearest Neighbors');
xlabel('X');
ylabel('Y');
zlabel('Z');
axis equal;
hold off;