import modal
from modal import FilePatternMatcher
image = (
    modal.Image.from_dockerfile(
        "./Dockerfile",
    )
    .add_local_dir(
        "FIM",
        remote_path = "/home/jovyan/FIM",
        copy=True,
    )
    .add_local_dir(
        "hmsc-hpc",
        remote_path="/home/jovyan/hmsc-hpc",
        copy=True,
    )
)

app = modal.App("notebook-images")

@app.function(image=image)
def notebook_images():
    pass