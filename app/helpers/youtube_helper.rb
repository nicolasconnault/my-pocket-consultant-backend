module YoutubeHelper
  def embed_youtube video_id
    match_data = /^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*/.match(video_id)
    if match_data[1]
      video_id = match_data[1]
    end
    '<span class="fr-video fr-fvc fr-dvb fr-draggable" contenteditable="false" draggable="true">
        <iframe width="440" height="247" src="//www.youtube.com/embed/' + video_id + '?wmode=opaque&rel=0&showinfo=0" frameborder="0" allowfullscreen=""></iframe>
     </span>'
  end
end
