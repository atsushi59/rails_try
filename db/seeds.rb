5.times do |index|
    Task.create!(
      title: "タイトル#{index + 1}",
      content: "内容#{index + 1}",
      is_done: false
    )
  end