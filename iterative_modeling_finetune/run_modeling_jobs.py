import sys
import subprocess

encid_list = sys.argv[1]
model = sys.argv[2]
output_overall_dir = sys.argv[3]
template_json = "/oak/stanford/groups/akundaje/patelas/arsenal-bpnet/example_jsons/bpnet_fit_example.json"
bpnet_overall_dir = "/oak/stanford/groups/akundaje/vir/tfatlas/processed_data/"
size_list = "5,10,25,50,75"

encid_list = [x.strip() for x in open(encid_list, "r")]

for encid in encid_list:
    loci_file = f"/oak/stanford/groups/akundaje/vir/tfatlas/processed_data/{encid}/peaks_inliers.bed.gz"
    negatives_file = f"/oak/stanford/groups/akundaje/vir/tfatlas/processed_data/{encid}/gc_neg_only.bed.gz"
    output_dir = f"{output_overall_dir}/{encid}/"
    launch_command = ["bash", "start_modeling_pipeline.sh", encid, model, size_list, template_json, loci_file, negatives_file, output_dir]
    print(encid)
    print(launch_command)
    subprocess.run(launch_command)